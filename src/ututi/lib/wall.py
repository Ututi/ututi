from collections import defaultdict

from pylons import tmpl_context as c

from sqlalchemy.sql.expression import and_
from sqlalchemy.sql.expression import not_
from sqlalchemy.orm import contains_eager, joinedload

from ututi.model.mailing import GroupMailingListMessage
from ututi.model.events import FileUploadedEvent
from ututi.model.events import MailinglistPostCreatedEvent
from ututi.model import File, ContentItem
from ututi.model import meta
from ututi.model.events import EventComment
from ututi.model.events import Event
from ututi.lib.base import render_def

class ObjectWrapper(dict):
    """
    A generic object wrapper. If we have the time this should be turned into a simple dict, that has all the attributes needed to render the wall.
    """
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
            .outerjoin(Event.user, Event.context, MailinglistPostCreatedEvent.message)\
            .options(contains_eager(Event.user, MailinglistPostCreatedEvent.message, Event.context))\
            .options(joinedload(FileUploadedEvent.file))\
            .filter(Event.parent == None)\
            .order_by(Event.created.desc(),
                      Event.event_type)\
            .limit(limit)

        return [ObjectWrapper(evt) for evt in evts.all()]

    def _set_wall_variables(self, events_hidable=False, limit=60):
        """This is just a shorthand method for setting common
        wall variables."""
        c.events = self._wall_events(limit)
        c.events_hidable = events_hidable
        self._load_event_data()


    def _load_event_data(self):

        #preload event children
        evt_ids = [evt.id for evt in c.events]
        children = meta.Session.query(Event)\
            .filter(Event.parent_id.in_(evt_ids))\
            .outerjoin(Event.user, Event.context, MailinglistPostCreatedEvent.message)\
            .options(contains_eager(Event.user, MailinglistPostCreatedEvent.message, Event.context))\
            .options(joinedload(FileUploadedEvent.file))\
            .order_by(Event.created.desc())

        if evt_ids:
            evt_collection = defaultdict(list)
            children = meta.Session.query(Event)\
                .outerjoin(Event.user, Event.context, MailinglistPostCreatedEvent.message, FileUploadedEvent.file)\
                .options(contains_eager(Event.user, MailinglistPostCreatedEvent.message, Event.context, FileUploadedEvent.file))\
                .filter(Event.parent_id.in_(evt_ids))\
                .order_by(Event.created.desc()).all()

        #preload event comments
        evt_ids.extend([ch.id for ch in children])
        comments = meta.Session.query(EventComment)\
            .options(joinedload(ContentItem.created))\
            .order_by(ContentItem.created_on.asc())\
            .filter(EventComment.event_id.in_(evt_ids)).all()
        comments_collection = defaultdict(list)
        for comm in comments:
            comments_collection[comm.event_id].append(comm)

        message_collection = defaultdict(list) #mailing list post collection
        msg_ids = [evt.internal.message_id for evt in c.events if isinstance(evt.internal, MailinglistPostCreatedEvent)]
        if msg_ids:
            messages = meta.Session.query(GroupMailingListMessage)\
                .filter(GroupMailingListMessage.thread_message_machine_id.in_(msg_ids))\
                .order_by(GroupMailingListMessage.thread_message_machine_id, GroupMailingListMessage.sent.asc()).all()

            # this is for loading attachments
            msg_ids = ([m.id for m in messages])
            attachments = meta.Session.query(File).filter(File.parent_id.in_(msg_ids)).all()
            attachments_collection = defaultdict(list)
            for att in attachments:
                attachments_collection[att.parent_id].append(att)

            for msg in messages:
                message_collection[msg.thread_message_machine_id].append(dict(
                        author=msg.author_or_anonymous,
                        created=msg.sent,
                        message=msg.body,
                        attachments=attachments_collection.get(msg.id, [])))

        for evt in children:
            #load comments here
            e = ObjectWrapper(evt)
            if comments_collection.has_key(evt.id):
                e['comments'] = comments_collection[evt.id]
            evt_collection[evt.parent_id].append(e)

        for evt in c.events:
            if isinstance(evt.internal, MailinglistPostCreatedEvent) and message_collection.has_key(evt.internal.message.thread_message_machine_id):
                evt['thread_posts'] = message_collection[evt.internal.message.thread_message_machine_id]
            if evt_collection.has_key(evt.id):
                evt['children'] = evt_collection[evt.id]
            if comments_collection.has_key(evt.id):
                evt['comments'] = comments_collection[evt.id]
