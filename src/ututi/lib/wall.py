from profilehooks import profile
from collections import defaultdict

from pylons.decorators import jsonify
from pylons import request
from pylons import tmpl_context as c
from pylons.i18n import _

from sqlalchemy.orm.query import aliased
from sqlalchemy.orm import eagerload, contains_eager
from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import func
from sqlalchemy.sql.expression import select

from ututi.lib.security import ActionProtector
from ututi.model.mailing import GroupMailingListMessage
from ututi.model.events import MailinglistPostCreatedEvent
from ututi.model import meta
from ututi.model.events import Event
from ututi.lib.base import render_def

class EventWrapper(dict):
    def __init__(self, internal):
        self.internal = internal

    def __getattr__(self, attr):
        if self.has_key(attr):
            return self[attr]
        elif hasattr(self.internal, attr):
            return getattr(self.internal, attr)
        else:
            raise NotImplementedError()

    def message_list(self):
        if 'thread_posts' in self.keys():
            return self['thread_posts']
        else:
            return self.internal.message_list()

    def wall_entry(self):
        return render_def('/sections/wall_entries.mako', self.internal.wall_entry_def, event=self)


class WallMixin(object):

    def _wall_events_query(self):
        """Should be implemented by subclasses."""
        raise NotImplementedError()

    def _wall_events(self, limit=250):
        """Returns threaded events, defined by _wall_events_query()"""

        event_query = self._wall_events_query()

        evts = event_query\
            .outerjoin(Event.user)\
            .filter(Event.parent == None)\
            .order_by(Event.created.desc(),
                      Event.event_type)\
            .limit(limit)

        return [EventWrapper(evt) for evt in evts.all()]

    def _set_wall_variables(self, events_hidable=False, limit=60):
        """This is just a shorthand method for setting common
        wall variables."""
        c.events = self._wall_events(limit)
        c.events_hidable = events_hidable
        self._load_event_data()


    def _load_event_data(self):

        evt_ids = [evt.id for evt in c.events]
        if evt_ids:
            evt_collection = dict()
            children = meta.Session.query(Event)\
                .filter(Event.parent_id.in_(evt_ids))\
                .order_by(Event.created.desc()).all()
            for evt in children:
                evt_collection.setdefault(evt.parent_id, [])
                evt_collection[evt.parent_id].append(evt)

        message_collection = dict() #mailing list post collection
        msg_ids = [evt.internal.message.thread_message_machine_id for evt in c.events if isinstance(evt.internal, MailinglistPostCreatedEvent)]
        if msg_ids:
            messages = meta.Session.query(GroupMailingListMessage)\
                .filter(GroupMailingListMessage.thread_message_machine_id.in_(msg_ids))\
                .order_by(GroupMailingListMessage.thread_message_machine_id, GroupMailingListMessage.sent.asc()).all()

            for msg in messages:
                message_collection.setdefault(msg.thread_message_machine_id, [])
                message_collection[msg.thread_message_machine_id].append(dict(
                        author=msg.author_or_anonymous,
                        created=msg.sent,
                        message=msg.body,
                        attachments=msg.attachments))

        for evt in c.events:
            if isinstance(evt.internal, MailinglistPostCreatedEvent) and message_collection.has_key(evt.internal.message.thread_message_machine_id):
                evt['thread_posts'] = message_collection[evt.internal.message.thread_message_machine_id]
            if evt_collection.has_key(evt.id):
                evt['children'] = evt_collection[evt.id]
