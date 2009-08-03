"""The application's model objects"""
import sys
import os
import hashlib
import sha, binascii
import warnings
from binascii import a2b_base64, b2a_base64
from routes.util import url_for
from pylons import request
from random import randrange
import pkg_resources
from datetime import date

from pylons import config

from sqlalchemy import orm, Column, Integer, Sequence, Table, select
from sqlalchemy.types import Unicode
from sqlalchemy.exc import DatabaseError, SAWarning
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import relation, backref
from sqlalchemy import func
from sqlalchemy.sql.expression import and_

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
                        Column('fullname', Unicode(assert_unicode=True)),
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

    #relationships between content items and tags
    global content_tags_table
    content_tags_table = Table("content_tags", meta.metadata,
                               autoload=True,
                               autoload_with=engine)

    global tags_table
    tags_table = Table("tags", meta.metadata,
                               Column('id', Integer, Sequence('tags_id_seq'), primary_key=True),
                               Column('title_short', Unicode(assert_unicode=True)),
                               Column('title', Unicode(assert_unicode=True)),
                               Column('description', Unicode(assert_unicode=True)),
                               useexisting=True,
                               autoload=True,
                               autoload_with=engine)
    tag_mapper = orm.mapper(Tag,
                            tags_table,
                            properties = {'logo': relation(File)})

    orm.mapper(LocationTag,
               inherits=tag_mapper,
               polymorphic_on=tags_table.c.tag_type,
               polymorphic_identity='location',
               properties = {'children': relation(LocationTag, backref=backref('parent', remote_side=tags_table.c.id))})

    orm.mapper(SimpleTag,
               inherits=tag_mapper,
               polymorphic_on=tags_table.c.tag_type,
               polymorphic_identity='')


    global files_table
    files_table = Table("files", meta.metadata,
                        Column('id', Integer, Sequence('files_id_seq'), primary_key=True),
                        Column('filename', Unicode(assert_unicode=True)),
                        Column('folder', Unicode(assert_unicode=True)),
                        Column('title', Unicode(assert_unicode=True)),
                        Column('description', Unicode(assert_unicode=True)),
                        autoload=True,
                        useexisting=True,
                        autoload_with=engine)
    orm.mapper(File, files_table)

    global subject_pages_table
    subject_pages_table = Table("subject_pages", meta.metadata,
                                autoload=True,
                                autoload_with=engine)

    global pages_table
    pages_table = Table("pages", meta.metadata,
                        autoload=True,
                        autoload_with=engine)
    orm.mapper(Page, pages_table,
               properties={'tags': relation(SimpleTag,
                                            secondary=content_tags_table)})

    global page_versions_table
    page_versions_table = Table("page_versions", meta.metadata,
                                Column('title', Unicode(assert_unicode=True)),
                                Column('content', Unicode(assert_unicode=True)),
                                autoload=True,
                                autoload_with=engine)
    orm.mapper(PageVersion, page_versions_table,
               properties={'author': relation(User),
                           'page': relation(Page,
                                            backref=backref('versions',
                                                            order_by=page_versions_table.c.created.desc()) )})

    global subject_files_table
    subject_files_table = Table("subject_files", meta.metadata,
                                autoload=True,
                                autoload_with=engine)
    global subjects_table
    subjects_table = Table("subjects", meta.metadata,
                           Column('id', Integer, Sequence('subjects_id_seq'), primary_key=True),
                           Column('title', Unicode(assert_unicode=True)),
                           Column('lecturer', Unicode(assert_unicode=True)),
                           autoload=True,
                           useexisting=True,
                           autoload_with=engine)
    orm.mapper(Subject, subjects_table,
               properties={'files': relation(File,
                                             secondary=subject_files_table),
                           'pages': relation(Page,
                                             secondary=subject_pages_table),
                           'location': relation(LocationTag),
                           'tags' : relation(SimpleTag,
                                             secondary=content_tags_table)})

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
               properties = {'user': relation(User, backref='memberships'),
                             'group': relation(Group, backref='members'),
                             'role': relation(GroupMembershipType)})


    global group_files_table
    group_files_table = Table("group_files", meta.metadata,
                              autoload=True,
                              autoload_with=engine)

    global groups_table
    groups_table = Table("groups", meta.metadata,
                         Column('title', Unicode(assert_unicode=True)),
                         Column('description', Unicode(assert_unicode=True)),
                         useexisting=True,
                         autoload=True,
                         autoload_with=engine)

    global group_watched_subjects_table
    group_watched_subjects_table = Table("group_watched_subjects", meta.metadata,
                                         autoload=True,
                                         autoload_with=engine)

    orm.mapper(Group, groups_table,
               properties ={'logo': relation(File),
                            'files': relation(File,
                                              secondary=group_files_table),
                            'watched_subjects': relation(Subject,
                                                         secondary=group_watched_subjects_table),
                            'location': relation(LocationTag),
                            'tags' : relation(SimpleTag,
                                              secondary=content_tags_table)})


    global user_monitored_subjects_table
    user_monitored_subjects_table = Table("user_monitored_subjects", meta.metadata,
                                        autoload=True,
                                        autoload_with=engine)

    orm.mapper(UserSubjectMonitoring, user_monitored_subjects_table,
               properties ={'subject': relation(Subject),
                            'user': relation(User)
                            })

    # ignoring error about unknown column type for now
    warnings.simplefilter("ignore", SAWarning)

    search_items_table = Table("search_items", meta.metadata,
                               autoload=True,
                               autoload_with=engine)

    warnings.simplefilter("default", SAWarning)

    orm.mapper(SearchItem, search_items_table,
               properties={'subject' : relation(Subject),
                           'group' : relation(Group),
                           'page' : relation(Page)})

    from ututi.model import mailing
    mailing.setup_orm(engine)


def initialize_db_defaults(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "model/defaults.sql").split(";;")
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


class UserSubjectMonitoring(object):

    def __init__(self, user, subject, ignored=False):
        self.user, self.subject, self.ignored = user, subject, ignored


users_table = None
user_monitored_subjects_table = None

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
            return meta.Session.query(Email).filter_by(email=username.lower()).one().user
        except NoResultFound:
            return None

    @classmethod
    def get_byid(cls, id):
        try:
            return meta.Session.query(User).filter_by(id=id).one()
        except NoResultFound:
            return None

    @property
    def watched_subjects(self):
        umst = user_monitored_subjects_table
        directly_watched_subjects = meta.Session.query(Subject)\
            .join((umst,
                   and_(umst.c.subject_id==subjects_table.c.id,
                        umst.c.subject_id==subjects_table.c.id)))\
            .filter(and_(umst.c.user_id == self.id,
                         umst.c.ignored == False))

        user_ignored_subjects = meta.Session.query(Subject)\
            .join((umst,
                   and_(umst.c.subject_id==subjects_table.c.id,
                        umst.c.subject_id==subjects_table.c.id)))\
            .filter(and_(umst.c.user_id == self.id,
                         umst.c.ignored == True))

        gwst = group_watched_subjects_table
        gmt = group_members_table
        group_watched_subjects = meta.Session.query(Subject)\
            .join((gwst,
                   and_(gwst.c.subject_id==subjects_table.c.id,
                        gwst.c.subject_id==subjects_table.c.id)))\
            .join((gmt, gmt.c.group_id == gwst.c.group_id))\
            .filter(gmt.c.user_id == self.id)
        return directly_watched_subjects.union(group_watched_subjects)\
            .except_(user_ignored_subjects).all()

    def _setWatchedSubject(self, subject, ignored):
        usm = meta.Session.query(UserSubjectMonitoring)\
            .filter_by(user=self, subject=subject).first()
        if usm is None:
            usm = UserSubjectMonitoring(self, subject, ignored=ignored)
            meta.Session.add(usm)
        else:
            usm.ignored = ignored

    def watchSubject(self, subject):
        self._setWatchedSubject(subject, ignored=False)

    def ignoreSubject(self, subject):
        self._setWatchedSubject(subject, ignored=True)

    def __init__(self, fullname, password, gen_password=True):
        self.fullname = fullname
        self.password = password
        if gen_password:
            self.password = generate_password(password)


email_table = None

class Email(object):
    """Class representing one email address of a user."""

    def __init__(self, email):
        self.email = email.strip().lower()


class Folder(list):

    def __init__(self, title):
        self.title = title


group_watched_subjects_table = None
groups_table = None

class Group(object):

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    @property
    def last_seen_members(self):
        gmt = group_members_table
        return meta.Session.query(User).join((gmt,
                                      gmt.c.user_id == users_table.c.id))\
                                .filter(gmt.c.group_id == self.id).all()

    @property
    def folders(self):
        result = {}
        for file in self.files:
            result.setdefault(file.folder, Folder(file.folder))
            if not file.isNullFile():
                result[file.folder].append(file)
        return sorted(result.values(), key=lambda f: f.title)

    def url(self, controller='group', action='group_home'):
        return url_for(controller=controller, action=action, id=self.id)

    def __init__(self, id, title=u'', location=None, year=None, description=u''):
        self.id = id.strip().lower()
        self.title = title
        self.location = location
        if year is None:
            year = date.today()
        self.year = year
        self.description = description


group_members_table = None

class GroupMember(object):
    """A membership object that associates a user with a group.

    It has attributes for `group', `user' and `membership_type',
    membership types are listed in group_membership_types table.
    """


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
    def get(cls, location, id):
        try:
            return meta.Session.query(cls).filter_by(id=id, location=location).one()
        except NoResultFound:
            return None

    @property
    def folders(self):
        result = {}
        for file in self.files:
            result.setdefault(file.folder, Folder(file.folder))
            if not file.isNullFile():
                result[file.folder].append(file)
        return sorted(result.values(), key=lambda f: f.title)

    @property
    def location_path(self):
        location = self.location
        path = []
        while location:
            path.append(location.title_short)
            location = location.parent
        return '/'.join(reversed(path))

    def url(self, controller='subject', action='home'):
        url = request.environ['routes.url']

        return url(controller=controller,
                   action=action,
                   id=self.id,
                   tags=self.location_path)

    def __init__(self, subject_id, title, location, lecturer=None):
        self.location = location
        self.title = title
        self.id = subject_id
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

    def __init__(self, title, content, author, created=None):
        """The first version of a page is created automatically."""
        self.add_version(title, content, author, created)

    def add_version(self, title, content, user, created=None):
        version = PageVersion(title, content, user, created)
        self.versions.append(version)

    @property
    def last_version(self):
        if self.versions:
            return self.versions[0]
        else:
            raise AttributeError("This page has no versions!")

    @property
    def title(self):
        return self.last_version.title

    @property
    def content(self):
        return self.last_version.content

    @property
    def author(self):
        return self.last_version.author

    @property
    def created(self):
        return self.last_version.created


page_versions_table = None

class PageVersion(object):
    """Class representing one version of a page."""

    def __init__(self, title, content, author, created=None):
        self.title = title
        self.content = content
        self.author = author
        if created is not None:
            self.created = created

class Tag(object):
    """Class representing tags in general."""

    def __init__(self, title, title_short, description):
        self.title = title
        self.description = description

    @classmethod
    def get(cls, id):
        tag = meta.Session.query(Tag)
        if isinstance(id, unicode):
            tag.filter_by(title=id.lower())
        else:
            tag.filter_by(id=id)
        try:
            return tag.one()
        except NoResultFound:
            return None

class SimpleTag(Tag):
    """Class for simple (i.e. not location or hierarchy -aware) tags."""
    def __init__(self, title):
        self.title = title.lower()


class LocationTag(Tag):
    """Class representing the university and faculty tags."""

    def __init__(self, title, title_short, description, parent=None):
        self.parent = parent
        self.title = title
        self.title_short = title_short
        self.description = description

    @property
    def path(self):
        location = self
        path = []
        while location:
            path.append(location.title_short)
            location = location.parent
        return list(reversed(path))

    def hierarchy(self):
        """Return a list of titles of all the parents of the tag, including the tag itself."""
        location = self
        path = []
        while location:
            path.append(location.title)
            location = location.parent
        return list(reversed(path))


    @classmethod
    def get(cls, path):

        if isinstance(path, unicode):
            path = path.split('/')

        tag = None
        for title_short in filter(bool, path):
            try:
                tag = meta.Session.query(LocationTag)\
                    .filter(func.lower(LocationTag.title_short)==title_short.lower()).filter_by(parent=tag).one()
            except NoResultFound:
                return None
        return tag

    @classmethod
    def get_by_title(cls, title):
        """A method to return the tag either by its full title or its short title.

        A list can be passed for hierarchical traversal.
        """
        if not isinstance(title, list):
            title = [title]

        tag = None
        for title_full in filter(bool, title):
            try:
                tag = meta.Session.query(LocationTag)\
                    .filter_by(title=title_full, parent=tag).one()
            except NoResultFound:
                try:
                    tag = meta.Session.query(LocationTag)\
                        .filter_by(title_short=title_full, parent=tag).one()
                except NoResultFound:
                    tag = None
                    break
        return tag


class File(object):
    """Class representing user-uploaded files."""

    def __init__(self, filename, title, mimetype=None, created=None,
                 description=u'', data=None, md5=None, folder=u''):
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
        self.folder = folder

    @classmethod
    def makeNullFile(cls, folder):
        result = cls(u"Null File", u"Null File", folder=folder)
        return result

    def isNullFile(self):
        return self.md5 == None

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


class SearchItem(object):
    @property
    def object(self):
        if self.group_id is not None:
            return self.group
        elif self.subject_id is not None:
            return self.subject
        elif self.page_id is not None:
            return self.page
        else:
            return None


# Reimports for convenience
from ututi.model.mailing import GroupMailingListMessage

# Events:
#
#   page added/modified
#   file added
#   message added
#   subject added/modified
#   member joined, invited, left, invitation accepted

# slicing
# user -> groups (pages, files, members?, messages) + subjects (pages, files)
# group -> subjects (pages, files) + group + pages + files + members

#   conversation, comment (feedback)
