"""The application's model objects"""
import sys
import hashlib
import pkg_resources
import sqlalchemy as sa
from sqlalchemy import orm, Column, Integer, Sequence
from sqlalchemy.exc import DatabaseError
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import relation

from ututi.model import meta


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


def initialize_db_defaults(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "config/defaults.sql").split(";")
    connection = meta.engine.connect()
    for statement in initial_db_data:
        statement = statement.strip()
        if (statement):
            try:
                connection.execute(statement)
            except DatabaseError, e:
                print >> sys.stderr, str(e)
    connection.close()


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

def encode_password(password):
    pwd_hash = hashlib.md5(password + 'ewze1ul6').hexdigest()
    return pwd_hash

users_table = None

class User(object):

    @classmethod
    def authenticate(cls, username, password):
        pwd_hash = encode_password(password)
        try:
            user = meta.Session.query(Email).filter_by(email=username).one().user
            if user.password == pwd_hash:
                return username
            else:
                return None
        except NoResultFound:
            return None
        return None

    @classmethod
    def get(cls, username):
        return meta.Session.query(Email).filter_by(email=username).one().user

    def __init__(self, fullname, password):
        self.fullname = fullname
        pwd_hash = encode_password(password)
        self.password = encode_password(password)

email_table = None

class Email(object):
    """Class representing one email of a user."""
    def __init__(self, email):
        self.email = email

