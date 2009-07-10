"""The application's model objects"""
import sys
import os
import hashlib
import sha, binascii
from binascii import a2b_base64, b2a_base64
from random import randrange
import pkg_resources

from pylons import config

from sqlalchemy import orm, Column, Integer, Sequence, Table
from sqlalchemy.exc import DatabaseError
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import relation, backref

from ututi.migration import GreatMigrator
from ututi.model import meta
from nous.mailpost import copy_chunked


def init_model(engine):
    """Call me before using any of the tables or classes in the model"""
    ## Reflected tables must be defined and mapped here
    meta.Session.configure(bind=engine)
    meta.engine = engine


def setup_orm(engine):
    global users_table
    users_table = Table("users", meta.metadata,
                        Column('id', Integer, Sequence('users_id_seq'), primary_key=True),
                        autoload=True,
                        autoload_with=engine)

    orm.mapper(User,
               users_table,
               properties = {'emails': relation(Email, backref='user'),
                             'logo': relation(File)})

    global emails_table
    emails_table = Table("emails", meta.metadata,
                         autoload=True,
                         autoload_with=engine)
    orm.mapper(Email, emails_table)

    global locationtags_table
    locationtags_table = Table("locationtags", meta.metadata,
                               Column('id', Integer, Sequence('locationtags_id_seq'), primary_key=True),
                               useexisting=True,
                               autoload=True,
                               autoload_with=engine)
    orm.mapper(LocationTag,
               locationtags_table,
               properties = {'children' : relation(LocationTag,
                                                   backref=backref('parent_item', remote_side=locationtags_table.c.id)),
                             'logo': relation(File)})
    global files_table
    files_table = Table("files", meta.metadata,
                        Column('id', Integer, Sequence('files_id_seq'), primary_key=True),
                        autoload=True,
                        useexisting=True,
                        autoload_with=engine)
    orm.mapper(File, files_table)


    global subjects_table
    subjects_table = Table("subjects", meta.metadata,
                           Column('id', Integer, Sequence('subjects_id_seq'), primary_key=True),
                           autoload=True,
                           autoload_with=engine)
    orm.mapper(Subject, subjects_table)


    global group_pages_table
    group_pages_table = Table("group_pages", meta.metadata,
                              autoload=True,
                              autoload_with=engine)
    global pages_table
    pages_table = Table("pages", meta.metadata,
                        autoload=True,
                        autoload_with=engine)
    orm.mapper(Page, pages_table)

    global page_versions_table
    page_versions_table = Table("page_versions", meta.metadata,
                                autoload=True,
                                autoload_with=engine)
    orm.mapper(PageVersion, page_versions_table,
               properties={'user': relation(User),
                           'page': relation(Page,
                                            backref=backref('versions',
                                                            order_by=page_versions_table.c.created.desc()) )})

    global group_membership_types_table
    group_membership_types_table = Table("group_membership_types", meta.metadata,
                                         autoload=True,
                                         autoload_with=engine)
    orm.mapper(GroupMembershipType,
               group_membership_types_table)

    global group_members_table
    group_members_table = Table("group_members", meta.metadata,
                                autoload=True,
                                autoload_with=engine)
    orm.mapper(GroupMember,
               group_members_table,
               properties = {'group' : relation(Group, backref='members'),
                             'user' : relation(User, backref='memberships'),
                             'role' : relation(GroupMembershipType)})


    global groups_table
    groups_table = Table("groups", meta.metadata,
                         autoload=True,
                         autoload_with=engine)
    orm.mapper(Group, groups_table,
               properties ={'logo': relation(File),
                            'pages': relation(Page,
                                              secondary=group_pages_table,
                                              backref='group')
                            })

    from ututi.model import mailing
    mailing.setup_orm(engine)


def initialize_db_defaults(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "config/defaults.sql").split(";;")
    connection = meta.engine.connect()
    for statement in initial_db_data:
        statement = statement.strip()
        if (statement):
            try:
                txn = connection.begin()
                connection.execute(statement)
                txn.commit()
            except DatabaseError, e:
                print >> sys.stderr, str(e)
                txn.rollback()
    connection.close()
    migrator = GreatMigrator(engine)
    migrator.initializeVersionning()


def teardown_db_defaults(engine, quiet=False):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "config/defaults.sql").splitlines()
    connection = meta.engine.connect()
    tx = connection.begin()
    connection.execute("drop schema public cascade")
    connection.execute("create schema public")
    tx.commit()
    connection.close()


def generate_salt():
    """Generate the salt used in passwords."""
    salt = ''
    for n in range(7):
        salt += chr(randrange(256))
    return salt


def generate_password(password):
    """Generate a hash for a given password."""
    salt = generate_salt()
    password = str(password)
    return b2a_base64(sha.new(password + salt).digest() + salt)[:-1]


def validate_password(reference, password):
    """Verify a password given the original hash."""
    try:
        ref = a2b_base64(reference)
    except binascii.Error:
        return False
    salt = ref[20:]
    compare = b2a_base64(sha.new(password + salt).digest() + salt)[:-1]
    return compare == reference


users_table = None

class User(object):

    @classmethod
    def authenticate(cls, username, password):
        try:
            user = meta.Session.query(Email).filter_by(email=username.strip().lower()).one().user
            if validate_password(user.password, password):
                return username
            else:
                return None
        except NoResultFound:
            return None
        return None

    @classmethod
    def get(cls, username):
        try:
            return meta.Session.query(Email).filter_by(email=username).one().user
        except NoResultFound:
            return None

    @classmethod
    def get_byid(cls, id):
        try:
            return meta.Session.query(User).filter_by(id=id).one()
        except NoResultFound:
            return None

    def __init__(self, fullname, password, gen_password = True):
        self.fullname = fullname
        self.password = password
        if gen_password:
            self.password = generate_password(password)


email_table = None

class Email(object):
    """Class representing one email address of a user."""

    def __init__(self, email):
        self.email = email.strip().lower()


groups_table = None

class Group(object):

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    def __init__(self, id, title = '', location = None, year = '', description = ''):
        self.id = id.strip().lower()
        self.title = title
        self.location = None #temporarily, until we get to setting locations
        self.year = year
        self.description = description


group_members_table = None

class GroupMember(object):
    pass


class GroupMembershipType(object):
    @classmethod
    def get(cls, membership_type):
        try:
            return meta.Session.query(cls).filter_by(membership_type=membership_type).one()
        except NoResultFound:
            return None


subjects_table = None

class Subject(object):
    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=int(id)).one()
        except:
            try:
                return meta.Session.query(cls).filter_by(text_id=str(id)).one()
            except NoResultFound:
                return None

    def __init__(self, title, text_id = None, lecturer = None):
        self.title = title

        if text_id != None:
            text_id = text_id.strip().lower()
        self.text_id = text_id

        self.lecturer = lecturer

pages_table = None

class Page(object):
    """Class representing user-editable wiki-like pages."""
    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=int(id)).one()
        except NoResultFound:
            return None

    def __init__(self, content, user, created=None):
        """The first version of a page is created automatically."""
        self.add_version(content, user, created)

    @property
    def content(self):
        if self.versions != []:
            return self.versions[0].content
        else:
            return None

    def add_version(self, content, user, created=None):
        version = PageVersion(content, user, created)
        self.versions.append(version)

    @property
    def user(self):
        if self.versions != []:
            return self.versions[0].user
        else:
            return None

    @property
    def created(self):
        if self.versions != []:
            return self.versions[0].created
        else:
            return None


page_versions_table = None

class PageVersion(object):
    """Class representing one version of a page."""

    def __init__(self, content, user, created = None):
        self.content = content
        self.user = user
        if created is not None:
            self.created = created


class LocationTag(object):
    """Class representing the university and faculty tags."""

    def __init__(self, title, title_short, description, parent=None):
        self.parent = parent
        self.title = title
        self.title_short = title_short
        self.description = description


class File(object):
    """Class representing user-uploaded files."""

    def __init__(self, filename, title, mimetype=None, created=None,
                 description='', data=None, md5=None):
        if data is not None:
            md5_digest = hashlib.md5(data).hexdigest()
            if md5 is not None:
                assert md5 == md5_digest
            self.md5 = md5_digest
            self.filesize = len(data)

        if md5 is not None:
            self.md5 = md5

        self.filename = filename
        self.title = title
        if mimetype is not None:
            self.mimetype = mimetype
        if created is not None:
            self.created = created
            self.modified = created
        self.description = description

    def filepath(self):
        """Calculate the path of a file, based on its md5 checksum."""
        dir_path = [config.get('files_path')]
        segment = ''
        for c in list(self.md5):
            segment += c
            if len(segment) > 7:
                dir_path.append(segment)
                segment = ''
        if segment:
            dir_path.append(segment)

        return os.path.join(*dir_path)

    def store(self, data):
        """Store a given file in the database and the filesystem."""
        self.md5 = self.hash_chunked(data)
        filename = self.filepath()
        if os.path.exists(filename):
            return

        if not os.path.exists(os.path.dirname(filename)):
            os.makedirs(os.path.dirname(filename))
        f = open(filename, 'w')
        size = copy_chunked(data, f, 4096)
        self.filesize = size

        f.close()

    def hash_chunked(self, file):
        """Calculate the checksum of a file in chunks."""
        chunk_size = 8 * 1024**2
        size = 0
        hash = hashlib.md5()

        while True:
            if isinstance(file, str):
                chunk = file[size:(size+chunk_size)]
            else:
                chunk = file.read(chunk_size)

            size += len(chunk)
            hash.update(chunk)
            if len(chunk) < chunk_size:
                break

        if not isinstance(file, str):
            file.seek(0)

        return hash.hexdigest()

# Reimports for convenience
from ututi.model.mailing import GroupMailingListMessage
