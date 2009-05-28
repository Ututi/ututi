"""The application's model objects"""
import sys
import hashlib
import pkg_resources
import sqlalchemy as sa
from sqlalchemy import orm
from sqlalchemy.exc import DatabaseError
from sqlalchemy.orm.exc import NoResultFound

from ututi.model import meta


def init_model(engine):
    """Call me before using any of the tables or classes in the model"""
    ## Reflected tables must be defined and mapped here
    meta.Session.configure(bind=engine)
    meta.engine = engine


def setup_orm(engine):
    global users_table
    users_table = sa.Table("users", meta.metadata, autoload=True,
                           autoload_with=engine)
    orm.mapper(User, users_table)


def initialize_db_defaults(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "config/defaults.sql").splitlines()
    connection = meta.engine.connect()
    for statement in initial_db_data:
        statement = statement.strip()
        if (statement and
            not statement.startswith("/*") and
            not statement.startswith('--')):
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
    for statement in initial_db_data:
        statement = statement.strip()
        if statement.startswith("---"):
            try:
                statement = statement[3:].strip()
                connection.execute(statement)
            except DatabaseError, e:
                if not quiet:
                    print >> sys.stderr, str(e)
    connection.close()


users_table = None

class User(object):

    @classmethod
    def authenticate(cls, username, password):
        pwd_hash = hashlib.md5(password + 'ewze1ul6').hexdigest()
        try:
            user = meta.Session.query(cls).filter_by(name=username, password=pwd_hash).one()
            return username
        except NoResultFound:
            return None
        return None

    @classmethod
    def get(cls, username):
        return meta.Session.query(cls).filter_by(name=username).one()

    def __init__(self, fullname, password):
        self.name = fullname
        self.password = password
