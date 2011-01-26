from pylons.decorators import jsonify
from pylons import request
from pylons import tmpl_context as c
from pylons.i18n import _

from sqlalchemy.orm.query import aliased
from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import func
from sqlalchemy.sql.expression import select

from ututi.lib.security import ActionProtector
from ututi.model.events import Event

class WallMixin(object):

    def _wall_events_query(self):
        """Should be implemented by subclasses."""
        raise NotImplementedError()

    def _wall_events(self, limit=60):
        """Returns threaded events, defined by _wall_events_query()"""

        #query for ordering events by their last subevent
        e = aliased(Event)
        child_query = select([e.created], e.parent_id==Event.id, order_by=e.created.desc(), limit=1).label('last')

        event_query = self._wall_events_query()

        return event_query\
            .filter(Event.parent == None)\
            .order_by(func.coalesce(child_query, Event.created).desc(),
                      Event.event_type)\
            .limit(limit).all()

    def _set_wall_variables(self, events_hidable=False):
        """This is just a shorthand method for setting common
        wall variables."""
        c.events = self._wall_events()
        c.events_hidable = events_hidable
