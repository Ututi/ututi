from sqlalchemy.schema import Table
from sqlalchemy.orm import relation
from sqlalchemy import orm

from ututi.model.mailing import GroupMailingListMessage
from ututi.model import File
from ututi.model import Page
from ututi.model import ContentItem
from ututi.model import meta, File


events_table = None

class Event(object):
    """Generic event class."""


class PageCreatedEvent(Event):
    """Event fired when a page is created.

    Has an attribute `page' pointing to the page that was added.
    """


class PageModifiedEvent(Event):
    """Event fired when a page is modified.

    Has an attribute `page' pointing to the page that was modified.
    """


class FileUploadedEvent(Event):
    """Event fired when a new file is uploaded.

    Has an attribute `file' pointing to the file that was uploaded.
    """


class SubjectCreatedEvent(Event):
    """Event fired when a new subject is created."""


class ForumPostCreatedEvent(Event):
    """Event fired when someone posts a message on group forums.

    Has an attribute `message' pointing to the message added.
    """


class GroupMemberJoinedEvent(Event):
    """Event fired when members join groups."""


class GroupMemberLeftEvent(Event):
    """Event fired when members leave groups."""


def setup_orm(engine):
    from ututi.model import files_table, pages_table
    from ututi.model.mailing import group_mailing_list_messages_table
    global events_table
    events_table = Table(
        "events",
        meta.metadata,
        autoload=True,
        autoload_with=engine)

    orm.mapper(Event,
               events_table,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='generic',
               properties = {'context': relation(ContentItem, backref='events')})

    orm.mapper(PageCreatedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='page_created',
               properties = {'page': relation(Page,
                                              primaryjoin=pages_table.c.id==events_table.c.page_id)})

    orm.mapper(PageModifiedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='page_modified',
               properties = {'page': relation(Page,
                                              primaryjoin=pages_table.c.id==events_table.c.page_id)})

    orm.mapper(FileUploadedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='file_uploaded',
               properties = {'file': relation(File,
                                              primaryjoin=files_table.c.id==events_table.c.file_id)})

    orm.mapper(SubjectCreatedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='subject_created')

    orm.mapper(ForumPostCreatedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='forum_post_created',
               properties = {'message': relation(GroupMailingListMessage,
                                                 primaryjoin=group_mailing_list_messages_table.c.id==events_table.c.message_id)})

    orm.mapper(GroupMemberJoinedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='member_joined')

    orm.mapper(GroupMemberLeftEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='member_left')

