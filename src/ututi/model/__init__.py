"""The application's model objects"""
import sys
import os
import hashlib
import sha, binascii
from binascii import a2b_base64, b2a_base64
from random import choice, randrange
from StringIO import StringIO

from pylons import config

import pkg_resources
import sqlalchemy as sa

from sqlalchemy import orm, Column, Integer, Sequence
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
    users_table = sa.Table("users", meta.metadata,
                           Column('id', Integer, Sequence('users_id_seq'), primary_key=True),
                           autoload=True,
                           autoload_with=engine)
    orm.mapper(User,
               users_table,
               properties = {'emails' : relation(Email, backref='user')})

    global emails_table
    emails_table = sa.Table("emails", meta.metadata,
                            autoload=True,
                            autoload_with=engine)
    orm.mapper(Email, emails_table)

    global locationtags_table
    locationtags_table = sa.Table("locationtags", meta.metadata,
                           Column('id', Integer, Sequence('locationtags_id_seq'), primary_key=True),
                           autoload=True,
                           autoload_with=engine)
    orm.mapper(LocationTag,
               locationtags_table,
               properties = {'children' : relation(LocationTag,
                                                   backref=backref('parent_item', remote_side=locationtags_table.c.id))})
    global files_table
    files_table = sa.Table("files", meta.metadata,
                           Column('id', Integer, Sequence('files_id_seq'), primary_key=True),
                           autoload=True,
                           autoload_with=engine)
    orm.mapper(File, files_table)

def initialize_db_defaults(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "config/defaults.sql").split(";")
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
            user = meta.Session.query(Email).filter_by(email=username).one().user
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

    def __init__(self, fullname, password, gen_password = True):
        self.fullname = fullname
        self.password = password
        if gen_password:
            self.password = generate_password(password)


email_table = None

class Email(object):
    """Class representing one email of a user."""
    def __init__(self, email):
        self.email = email


class LocationTag(object):
    """Class representing the university and faculty tags."""
    def __init__(self, title, title_short, description, parent=None):
        self.parent = parent
        self.title = title
        self.title_short = title_short
        self.description = description

class File(object):
    """Class representing user-uploaded files."""
    def __init__(self, filename, title, mimetype=None, created=None, description='', data=None):
        if data is not None:
            self.md5 = hashlib.md5(data).hexdigest()
            self.filesize = len(data)
        self.filename = filename
        self.title = title
        if mimetype is not None:
            self.mimetype = mimetype
        if created is not None:
            self.created = created
            self.modified = created
        self.description = description

    def filepath(self):
        dir_path = [config.get('files_path', '/tmp')]
        segment = ''
        for c in list(self.md5):
            segment += c
            if len(segment) > 7:
                dir_path.append(segment)
                segment = ''
        if segment:
            dir_path.append(segment)

        return os.path.join(*dir_path)

    def store(self, filename, data):
        self.filename = filename
        self.md5 = hashlib.md5(data).hexdigest()
        self.filesize = len(data)

        filename = self.filepath()
        if os.path.exists(filename):
            return

        if not os.path.exists(os.path.dirname(filename)):
            os.makedirs(os.path.dirname(filename))
        f = open(filename, 'w')
        size = copy_chunked(StringIO(data), f, 4096)
        f.close()
