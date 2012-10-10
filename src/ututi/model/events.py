import cgi
import warnings
import logging

from sqlalchemy import orm, Column
from sqlalchemy.exc import SAWarning
from sqlalchemy.schema import Table
from sqlalchemy.orm import backref
from sqlalchemy.orm import relation
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.types import Unicode
from pylons import url
from pylons.i18n import ungettext, _

from ututi.model.mailing import GroupMailingListMessage
from ututi.model import Group, Subject, User, File, Page, ContentItem, ForumPost, OutgoingGroupSMSMessage, PrivateMessage
from ututi.model import meta
from ututi.lib.helpers import link_to, ellipsis, when
from ututi.lib.base import render_def

log = logging.getLogger(__name__)

class Event(object):
    """Generic event class."""

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    def when(self):
        """This is deprecated. Apply helper method directly instead."""
        return when(self.created)

    def isEmptyFile(object):
        return False

    def render(self):
        raise NotImplementedError()

    def wall_entry(self):
        if not hasattr(self, 'wall_entry_def'):
            raise NotImplementedError()

        return render_def('/sections/wall_entries.mako', self.wall_entry_def, event=self)

    @property
    def wall_entry_def(self):
        return self.event_type

    def post_comment(self, comment):
        # XXX: it should be checked if this user can post
        # comment to this event. The following check is not
        # very nice too.
        if isinstance(self, Commentable):
            # TODO: why doesn't the following work?
            # self.comments.append(comment)
            comment.event = self

    def children_comments(self):
        """Count the number of comments, children of this event have."""
        return sum([len(child.comments) for child in self.children])

    @classmethod
    def event_types(cls):
        types = meta.Session.query(meta.metadata.tables['events'].c.event_type).distinct().all()
        return [evt[0] for evt in types]


class EventComment(ContentItem):
    """Event comment ORM class."""

    def __init__(self, author, content):
        self.created = author
        self.content = content


class MessagingEventMixin():
    """This mixin defines common interface for messaging related events 
    that are threaded and have messaging actions in the wall."""

    def message_list(self):
        """
        Returns a simple dict list with post information:

            {"author": User,
             "created": datetime,
             "message": message string,
             "attachments": file list, may be omitted}

        Should be listed chronologically.
        """
        raise NotImplementedError()

    def reply_action(self):
        """
        Returns reply action url.

        Note: the posted parameter is always called 'message'.
        This should be fixed so that this method explicitly returns
        what parameter is being posted.
        """
        raise NotImplementedError()


class Commentable(MessagingEventMixin):
    """Standard implementation of MessagingEventMixin that lists event
    comments and allows comment actions."""

    def message_list(self):
        """MessagingEventMixin implementation."""
        return [dict(author=c.created,
                     created=c.created_on,
                     message=c.content) for c in self.comments]

    def reply_action(self):
        """MessagingEventMixin implementation."""
        return url(controller='wall', action='eventcomment_reply', event_id=self.id)


class PageEventBase(Event):

    category = 'page'

    @property
    def page_deleted_on(self):
        return self.page.deleted_on

    @property
    def page_title(self):
        return self.page.title


class PageCreatedEvent(PageEventBase, Commentable):
    """Event fired when a page is created.

    Has an attribute `page' pointing to the page that was added.
    """

    def text_news(self):
        return _('Page %(page_title)s (%(page_url)s) was created.') % {
            'page_title': self.page.title,
            'page_url': self.page.url(qualified=True)}

    def html_news(self):
        return _('Page %(page_title)s was created.') % {
            'page_title': link_to(self.context.title,
                                  self.context.url(qualified=True))}

    def render(self):
        return _("New page %(link_to_page)s of a subject %(link_to_subject)s was created") % {
            'link_to_subject': link_to(self.context.title, self.context.url()),
            'link_to_page': link_to(self.page.title, self.page.url())}


class PageModifiedEvent(PageEventBase, Commentable):
    """Event fired when a page is modified.

    Has an attribute `page' pointing to the page that was modified.
    """

    def text_news(self):
        if not self.page.isDeleted():
            return _('Page %(page_title)s (%(page_url)s) was updated.') % {
                'page_title': self.page.title,
                'page_url': self.page.url(qualified=True)}
        else:
            return _('Page %(page_title)s was updated.') % {
                'page_title': self.page.title}

    def html_news(self):
        if not self.page.isDeleted():
            return _('Page %(page_title)s was updated.') % {
                'page_title': link_to(self.page.title,
                                      self.page.url(qualified=True))}
        else:
            return _('Page %(page_title)s was updated.') % {
                'page_title': self.page.title}

    def render(self):
        if not self.page.isDeleted():
            return _("Page %(page)s of a subject %(subject)s was updated") % {
                'subject': self.context.title,
                'page': self.page.title}
        else:
            return _("Page %(link_to_page)s of a subject %(link_to_subject)s was updated") % {
                'link_to_subject': link_to(self.context.title, self.context.url()),
                'link_to_page': link_to(self.page.title, self.page.url())}


class FileUploadedEvent(Event, Commentable):
    """Event fired when a new file is uploaded.

    Has an attribute `file' pointing to the file that was uploaded.
    """

    category = 'file'

    def isEmptyFile(self):
        return self.file.isNullFile()

    def file_link(self, short=False):
        limit = 23 if short else None
        if self.file.isDeleted():
            return ellipsis(self.file.title, limit) if short else self.file.title
        else:
            return link_to(self.file.title, self.file.url(qualified=False), limit)

    def text_news(self):
        if not self.file.isDeleted():
            return _('File %(file_title)s (%(file_url)s) was uploaded.') % {
                   'file_title': self.file.title,
                   'file_url': self.file.url(qualified=True)}
        else:
            return _('File %(file_title)s was uploaded.') % {'file_title': self.file.title}

    def html_news(self):
        if not self.file.isDeleted():
            return _('File %(file_title)s was uploaded.') % {
                   'file_title': link_to(self.file.title,
                                         self.file.url(qualified=True))}
        else:
            return _('File %(file_title)s was uploaded.') % {'file_title': self.file.title}


    def render(self):
        if self.file.md5 is not None:
            if isinstance(self.context, Subject):
                return _("A new file %(link_to_file)s for a subject %(link_to_subject)s was uploaded") % {
                    'link_to_subject': link_to(self.context.title, self.context.url()),
                    'link_to_file': self.file_link()}
            elif isinstance(self.context, Group):
                return _("A new file %(link_to_file)s for a group %(link_to_group)s was uploaded") % {
                    'link_to_group': link_to(self.context.title, self.context.url()),
                    'link_to_file': self.file_link()}
        else:
            if isinstance(self.context, Subject):
                return _("A new folder '%(folder_title)s' for a subject %(link_to_subject)s was created") % {
                    'link_to_subject': link_to(self.context.title, self.context.url()),
                    'folder_title': self.file.folder}
            elif isinstance(self.context, Group):
                return _("A new folder '%(folder_title)s' for a group %(link_to_group)s was uploaded") % {
                    'link_to_group': link_to(self.context.title, self.context.url()),
                    'folder_title': self.file.folder}

    @property
    def context_type(self):
        return self.file.parent.content_type

    @property
    def md5(self):
        return self.file.md5

    @property
    def file_deleted_on(self):
        return self.file.deleted_on


class SubjectCreatedEvent(Event):
    """Event fired when a new subject is created."""

    def render(self):
        return _("New subject %(link_to_subject)s was created") % {
            'link_to_subject': link_to(self.context.title, self.context.url())}


class GroupCreatedEvent(Event):
    """Event fired when a new group is created."""

    def render(self):
        return _("New group %(link_to_group)s was created") % {
            'link_to_group': link_to(self.context.title, self.context.url())}


class SubjectModifiedEvent(Event):
    """Event fired when a subject is modified."""

    def render(self):
        return _("Subject %(link_to_subject)s was modified") % {
            'link_to_subject': link_to(self.context.title, self.context.url())}


class PostCreatedEventBase(Event):
    """Base class for mailing list post related events.""" 

    def link_to_author(self):
        """Should be deprecated, when the old wall is gone."""
        info_dict = self.message.info_dict()
        return link_to(info_dict['author']['title'], info_dict['author']['url'])


class TeacherMessageEvent(Event):
    """Event fired when a teacher posts a message to a group that has a forum.

    Current implementation is that such group's members receive individual emails from the teacher.
    We need to be able to show the teacher's message on the wall.

    The message is stored in the 'data' attribute (text).
    """

    def render(self):
        return _("Teacher %(link_to_author)s sent message to the group %(link_to_group)s.") % {
            'link_to_author': link_to(self.user.fullname, self.user.url()),
            'link_to_group': link_to(self.context.title, self.context.url())}


class MailinglistPostCreatedEvent(PostCreatedEventBase, MessagingEventMixin):
    """Event fired when someone posts a message on the group mailing list.

    Has an attribute `message' pointing to the message added.
    """

    def render(self):
        return _("New email post %(link_to_message)s was posted on %(link_to_group)s mailing list") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_message': link_to(self.message.subject, self.message.url())}

    def message_list(self):
        """MessagingEventMixin implementation."""
        return [dict(author=m.author_or_anonymous, created=m.sent,
                     message=m.body, attachments=m.attachments)
                for m in self.message.thread.posts]

    def reply_action(self):
        """MessagingEventMixin implementation."""
        return url(controller='wall', action='mailinglist_reply',
                   thread_id=self.message.thread.id, group_id=self.message.thread.group.group_id)

    @property
    def ml_message(self):
        return self.message.body

    @property
    def ml_thread_id(self):
        return self.message.thread.id

    @property
    def ml_group_id(self):
        return self.message.group_id

    @property
    def ml_author(self):
        return self.message.author


class ModeratedPostCreated(PostCreatedEventBase):
    """Event fired when someone posts a message on the moderation queue.

    Has an attribute `message' pointing to the message added.
    """

    category = 'moderation'

    def count_of_messages_in_queue(self):
        return meta.Session.query(ModeratedPostCreated).filter_by(object_id=self.context.id).count()

    def text_news(self):
        count = self.count_of_messages_in_queue()
        text = ungettext('There is %(number_of_messages)d message in the moderation queue (%(moderation_queue_link)s)',
                         'There are %(number_of_messages)d messages in the moderation queue (%(moderation_queue_link)s)', count) % {
            'number_of_messages': count,
            'moderation_queue_link': self.context.url(controller='mailinglist', action='administration', qualified=True)}
        return text

    def html_news(self):
        count = self.count_of_messages_in_queue()
        text = ungettext('There is %(number_of_messages)d message waiting in the <a href="%(moderation_queue_link)s">moderation queue</a>',
                         'There are %(number_of_messages)d waiting in the <a href="%(moderation_queue_link)s">moderation queue</a>', count) % {
            'number_of_messages': count,
            'moderation_queue_link': self.context.url(controller='mailinglist', action='administration', qualified=True)}
        return text

    def render(self):
        return _("New email post %(link_to_message)s was posted in %(link_to_group)s moderation queue") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_message': link_to(self.message.subject, self.message.url())}

    @property
    def ml_message(self):
        return self.message.body



class ForumPostCreatedEvent(Event, MessagingEventMixin):
    """Event fired when someone posts a message on group forums.

    Has an attribute `post' pointing to the message added.
    """


    def render(self):
        return _("New forum post %(link_to_message)s posted on %(link_to_group)s forums") % {
            'link_to_group': link_to(self.context.title, self.context.url(new=True)),
            'link_to_message': link_to(self.post.title, self.post.url(new=True))}

    def message_list(self):
        """MessagingEventMixin implementation."""
        category_id = self.post.category_id
        thread_id = self.post.thread_id
        forum_posts = meta.Session.query(ForumPost)\
            .filter_by(category_id=category_id,
                       thread_id=thread_id)\
            .order_by(ForumPost.created_on)\
            .all()
        return [dict(author=m.created, created=m.created_on, message=m.message)
                for m in forum_posts]

    def reply_action(self):
        """MessagingEventMixin implementation."""
        return url(controller='wall', action='forum_reply',
                   group_id=self.context.group_id,
                   category_id=self.post.category_id,
                   thread_id=self.post.thread_id)

    @property
    def fp_message(self):
        return self.post.message

    @property
    def fp_category_id(self):
        return self.post.category_id

    @property
    def fp_thread_id(self):
        return self.post.thread_id


class SMSMessageSentEvent(Event):
    """Event fired when someone sends an SMS message to the group."""

    def render(self):
        return _("%(link_to_author)s sent an SMS: <em>%(text)s</em>") % {
            'link_to_author': link_to(self.outgoing_sms.sender.fullname, self.outgoing_sms.sender.url()),
            'text': self.sms_text()}

    def sms_text(self):
        return cgi.escape(self.outgoing_sms.message_text)

    def sms_created(self):
        return self.outgoing_sms.created


class PrivateMessageSentEvent(Event):
    """Event fired when someone sends a private message to the user."""

    def render(self):
        return _("%(link_to_author)s sent an private message: <em>%(text)s</em>") % {
            'link_to_author': link_to(self.private_message.sender.fullname, self.private_message.sender.url()),
            'text': self.message_text()}

    def message_text(self):
        """Deprecated."""
        log.warn('message_text of PrivateMessageSentEvent is deprecated.')
        return cgi.escape(self.private_message.content)


class GroupMemberJoinedEvent(Event):
    """Event fired when members join groups."""

    def render(self):
        return _("Member %(link_to_user)s joined the group %(link_to_group)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_user': link_to(self.user.fullname, self.user.url())}


class GroupMemberLeftEvent(Event):
    """Event fired when members leave groups."""

    def render(self):
        return _("Member %(link_to_user)s left the group %(link_to_group)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_user': link_to(self.user.fullname, self.user.url())}


class GroupStartedWatchingSubjects(Event):
    """Event fired when group starts watching a subject."""

    def render(self):
        return _("Group %(link_to_group)s started watching subject %(link_to_subject)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_subject': link_to(self.subject.title, self.subject.url())}


class GroupStoppedWatchingSubjects(Event):
    """Event fired when group stops watching a subject."""

    def render(self):
        return _("Group %(link_to_group)s stopped watching subject %(link_to_subject)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_subject': link_to(self.subject.title, self.subject.url())}


def setup_tables(engine):
    warnings.simplefilter("ignore", SAWarning)
    Table("events",
          meta.metadata,
          autoload=True,
          autoload_with=engine)
    warnings.simplefilter("default", SAWarning)

    global event_comments_table
    event_comments_table = Table(
        "event_comments",
        meta.metadata,
        Column('content', Unicode()),
        autoload=True,
        autoload_with=engine)


def setup_orm():
    tables = meta.metadata.tables
    event_mapper = orm.mapper(Event,
               tables['events'],
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='generic',
               properties = {'context': relation(ContentItem, backref=backref('events', cascade='save-update, merge, delete')),
                             'user': relation(User, backref='events',
                                              primaryjoin=tables['users'].c.id==tables['events'].c.author_id),
                             'children': relation(Event,
                                                  order_by=tables['events'].c.id.asc(),
                                                  backref=backref('parent',
                                                                  remote_side=tables['events'].c.id))})

    orm.mapper(EventComment, tables['event_comments'],
               inherits=ContentItem,
               inherit_condition=tables['event_comments'].c.id==ContentItem.id,
               polymorphic_identity='event_comment',
               polymorphic_on=tables['content_items'].c.content_type,
               properties = {
                 'event': relation(Event,
                      primaryjoin=tables['event_comments'].c.event_id==tables['events'].c.id,
                      backref=backref('comments',
                                      order_by=tables['content_items'].c.created_on.asc()))
               })

    orm.mapper(PageCreatedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='page_created',
               properties = {'page': relation(Page,
                                              primaryjoin=tables['pages'].c.id==tables['events'].c.page_id)})

    orm.mapper(PageModifiedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='page_modified',
               properties = {'page': relation(Page,
                                              primaryjoin=tables['pages'].c.id==tables['events'].c.page_id)})

    orm.mapper(FileUploadedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='file_uploaded',
               properties = {'file': relation(File,
                                              primaryjoin=tables['files'].c.id==tables['events'].c.file_id)})

    orm.mapper(SubjectCreatedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='subject_created')

    orm.mapper(GroupCreatedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='group_created')

    orm.mapper(SubjectModifiedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='subject_modified')

    orm.mapper(MailinglistPostCreatedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='mailinglist_post_created',
               properties = {'message': relation(GroupMailingListMessage,
                                                 primaryjoin=tables['group_mailing_list_messages'].c.id==tables['events'].c.message_id)})

    orm.mapper(TeacherMessageEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='teacher_message',
               )

    orm.mapper(ModeratedPostCreated,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='moderated_post_created',
               properties = {'message': relation(GroupMailingListMessage,
                                                 primaryjoin=tables['group_mailing_list_messages'].c.id==tables['events'].c.message_id)})

    orm.mapper(ForumPostCreatedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='forum_post_created',
               properties = {'post': relation(ForumPost,
                                 primaryjoin=tables['forum_posts'].c.id==tables['events'].c.post_id)})

    orm.mapper(SMSMessageSentEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='sms_message_sent',
               properties={'outgoing_sms': relation(OutgoingGroupSMSMessage,
                    primaryjoin=tables['outgoing_group_sms_messages'].c.id==tables['events'].c.sms_id)})

    orm.mapper(PrivateMessageSentEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='private_message_sent',
               properties={'private_message': relation(PrivateMessage,
                                                       primaryjoin=tables['private_messages'].c.id==tables['events'].c.private_message_id),
                           'recipient': relation(User,
                                                 primaryjoin=tables['users'].c.id==tables['events'].c.recipient_id)})

    orm.mapper(GroupMemberJoinedEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='member_joined')

    orm.mapper(GroupMemberLeftEvent,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='member_left')

    orm.mapper(GroupStartedWatchingSubjects,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='group_started_watching_subject',
               properties = {'subject': relation(Subject,
                                                 primaryjoin=tables['subjects'].c.id==tables['events'].c.subject_id)})

    orm.mapper(GroupStoppedWatchingSubjects,
               inherits=event_mapper,
               polymorphic_on=tables['events'].c.event_type,
               polymorphic_identity='group_stopped_watching_subject',
               properties = {'subject': relation(Subject,
                                                 primaryjoin=tables['subjects'].c.id==tables['events'].c.subject_id)})


