"""SQLAlchemy Metadata and Session object"""
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import scoped_session, sessionmaker

__all__ = ['Session', 'engine', 'metadata', 'DeclarativeModel']

# SQLAlchemy database engine. Updated by model.init_model()
engine = None


from sqlalchemy.orm.interfaces import SessionExtension
class UtutiSessionExtension(SessionExtension):

    def after_begin(self, session, transaction, connection):

        session.execute("SET LOCAL ututi.active_user TO 0")
        from pylons import config
        session.execute("SET default_text_search_config TO '%s'" % config.get('default_search_dict', 'public.universal'))

        from pylons import request
        try:
            environ = request.environ
        except TypeError:
            return

        user_id = environ.get('repoze.who.identity', None)
        if user_id is not None:
            session.execute("SET LOCAL ututi.active_user TO %d" % user_id)

# SQLAlchemy session manager. Updated by model.init_model()
Session = scoped_session(sessionmaker(extension=[UtutiSessionExtension()]))

def set_active_user(user_id):
    assert isinstance(user_id, (int, long)) or user_id == '', repr(user_id)
    if isinstance(user_id, (int, long)):
        Session.execute("SET LOCAL ututi.active_user TO %d" % user_id)
    else:
        Session.execute("SET LOCAL ututi.active_user TO ''")

from sqlalchemy.ext.declarative import declarative_base, DeferredReflection
# Global metadata. If you have multiple databases with overlapping table
# names, you'll need a metadata for each database
Base = declarative_base()
metadata = Base.metadata

class DeclarativeModel(DeferredReflection, Base):
    __abstract__ = True

    @classmethod
    def get(cls, id):
        try:
            return Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    @classmethod
    def all(cls):
        return Session.query(cls).all()

    def delete(self):
        Session.delete(self)
