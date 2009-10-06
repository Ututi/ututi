"""SQLAlchemy Metadata and Session object"""
from sqlalchemy import MetaData
from sqlalchemy.orm import scoped_session, sessionmaker

__all__ = ['Session', 'engine', 'metadata']

# SQLAlchemy database engine. Updated by model.init_model()
engine = None


from sqlalchemy.orm.interfaces import SessionExtension
class UtutiSessionExtension(SessionExtension):

    def after_begin(self, session, transaction, connection):
        from pylons import request, config
        try:
            environ = request.environ
        except TypeError:
            return

        session.execute("SET ututi.active_user TO 0")
        user_id = environ.get('repoze.who.identity', None)
        if user_id is not None:
            session.execute("SET ututi.active_user TO %d" % user_id)

        language = config.get('lang', 'en')
        if language == 'en':
            language = 'pg_catalog.english'
        if language in ('lt', 'pl'):
            language == 'public.%s' % language
        session.execute("SET default_text_search_config TO '%s'" % language)


# SQLAlchemy session manager. Updated by model.init_model()
Session = scoped_session(sessionmaker(extension=[UtutiSessionExtension()]))

# Global metadata. If you have multiple databases with overlapping table
# names, you'll need a metadata for each database
metadata = MetaData()
