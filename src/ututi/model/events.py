import datetime

from sqlalchemy.schema import Table
from sqlalchemy.orm import backref
from sqlalchemy.orm import relation
from sqlalchemy import orm
from pylons.i18n import ungettext, _

from ututi.model.mailing import GroupMailingListMessage
from ututi.model import Group
from ututi.model import Subject
from ututi.model import User
from ututi.model import File
from ututi.model import Page
from ututi.model import ContentItem
from ututi.model import meta
from ututi.lib.helpers import link_to, ellipsis

events_table = None

class Event(object):
    """Generic event class."""

    def when(self):
        difference = datetime.datetime.utcnow() - self.created
        if datetime.timedelta(seconds=60) > difference:
            num = difference.seconds
            return ungettext("%(num)s second ago",
                             "%(num)s seconds ago",
                             num) % {'num': num}
        elif datetime.timedelta(seconds=3600) > difference:
            num = difference.seconds / 60
            return ungettext("%(num)s minute ago",
                             "%(num)s minutes ago",
                             num) % {'num': num}
        elif datetime.timedelta(1) > difference:
            num = difference.seconds / 3600
            return ungettext("%(num)s hour ago",
                             "%(num)s hours ago",
                             num) % {'num': num}
        elif datetime.timedelta(5) > difference:
            num = difference.days
            return ungettext("%(num)s day ago",
                             "%(num)s days ago",
                             num) % {'num': num}
        else:
            return self.created.strftime("%Y-%m-%d")

    def isEmptyFile(object):
        return False

    def render(self):
        raise NotImplementedError()

    def shortened(self, context=True):
        raise NotImplementedError()


class PageCreatedEvent(Event):
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

    def shortened(self, context=True):
        if context:
            return "%(link_to_context)s > %(link_to_page)s" % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_page': link_to(self.page.title, self.page.url(), 23)}
        else:
            return "%(link_to_page)s" % {
                'link_to_page': link_to(self.page.title, self.page.url(), 35)}


class PageModifiedEvent(Event):
    """Event fired when a page is modified.

    Has an attribute `page' pointing to the page that was modified.
    """

    def text_news(self):
        return _('Page %(page_title)s (%(page_url)s) was updated.') % {
            'page_title': self.page.title,
            'page_url': self.page.url(qualified=True)}

    def html_news(self):
        return _('Page %(page_title)s was updated.') % {
            'page_title': link_to(self.page.title,
                                  self.page.url(qualified=True))}

    def render(self):
        return _("Page %(link_to_page)s of a subject %(link_to_subject)s was updated") % {
            'link_to_subject': link_to(self.context.title, self.context.url()),
            'link_to_page': link_to(self.page.title, self.page.url())}

    def shortened(self, context=True):
        if context:
            return "%(link_to_context)s > %(link_to_page)s" % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_page': link_to(self.page.title, self.page.url(), 23)}
        else:
            return "%(link_to_page)s" % {'link_to_page': link_to(self.page.title, self.page.url(), 35)}


class FileUploadedEvent(Event):
    """Event fired when a new file is uploaded.

    Has an attribute `file' pointing to the file that was uploaded.
    """

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

    def shortened(self, context=True):
        if context:
            if self.file.md5 is not None:
                return "%(link_to_context)s > %(link_to_file)s" % {
                    'link_to_context': link_to(self.context.title, self.context.url(), 23),
                    'link_to_file': self.file_link(short=True)}
            else:
                return _("%(link_to_context)s > %(link_to_file)s (new) ") % {
                    'link_to_context': link_to(self.context.title, self.context.url(), 23),
                    'link_to_file': self.file.folder}
        else:
            if self.file.md5 is not None:
                return "%(link_to_file)s" % {'link_to_file': self.file_link(short=True)}
            else:
                return _("%(link_to_file)s (new)") % {'link_to_file': self.file.folder}


class SubjectCreatedEvent(Event):
    """Event fired when a new subject is created."""

    def render(self):
        return _("New subject %(link_to_subject)s was created") % {
            'link_to_subject': link_to(self.context.title, self.context.url())}

    def shortened(self, context=True):
        return _("%(link_to_context)s (new subject)") % {
                'link_to_context': link_to(self.context.title, self.context.url(), 25)}


class SubjectModifiedEvent(Event):
    """Event fired when a subject is modified."""

    def render(self):
        return _("Subject %(link_to_subject)s was modified") % {
            'link_to_subject': link_to(self.context.title, self.context.url())}

    def shortened(self, context=True):
        return _("%(link_to_context)s (subject changed)") % {
                'link_to_context': link_to(self.context.title, self.context.url(), 25)}


class ForumPostCreatedEvent(Event):
    """Event fired when someone posts a message on group forums.

    Has an attribute `message' pointing to the message added.
    """

    def render(self):
        return _("New forum post %(link_to_message)s was posted on %(link_to_group)s forums") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_message': link_to(self.message.subject, self.message.url())}

    def shortened(self, context=True):
        if context:
            return "%(link_to_context)s > %(link_to_message)s" % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_message': link_to(self.message.subject, self.message.url(), 23)}
        else:
            return "%(link_to_message)s" % {
                'link_to_message': link_to(self.message.subject, self.message.url(), 35)}


class GroupMemberJoinedEvent(Event):
    """Event fired when members join groups."""

    def render(self):
        return _("Member %(link_to_user)s joined the group %(link_to_group)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_user': link_to(self.user.fullname, self.user.url())}

    def shortened(self, context=True):
        if context:
            return _("%(link_to_context)s > %(link_to_user)s (joined)") % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_user': link_to(self.user.fullname, self.user.url(), 23)}
        else:
            return _("%(link_to_user)s (joined)") % {
                'link_to_user': link_to(self.user.fullname, self.user.url(), 30)}


class GroupMemberLeftEvent(Event):
    """Event fired when members leave groups."""

    def render(self):
        return _("Member %(link_to_user)s left the group %(link_to_group)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_user': link_to(self.user.fullname, self.user.url())}

    def shortened(self, context=True):
        if context:
            return _("%(link_to_context)s > %(link_to_user)s (left)")  % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_user': link_to(self.user.fullname, self.user.url(), 23)}
        else:
            return _("%(link_to_user)s (left)") % {
                'link_to_user': link_to(self.user.fullname, self.user.url(), 30)}


class GroupStartedWatchingSubjects(Event):
    """Event fired when group starts watching a subject."""

    def render(self):
        return _("Group %(link_to_group)s started watching subject %(link_to_subject)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_subject': link_to(self.subject.title, self.subject.url())}

    def shortened(self, context=True):
        if context:
            return "%(link_to_context)s > %(link_to_subject)s" % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_subject': link_to(self.subject.title, self.subject.url(), 23)}
        else:
            return "%(link_to_subject)s" % {
                'link_to_subject': link_to(self.subject.title, self.subject.url(), 35)}


class GroupStoppedWatchingSubjects(Event):
    """Event fired when group stops watching a subject."""

    def render(self):
        return _("Group %(link_to_group)s stopped watching subject %(link_to_subject)s") % {
            'link_to_group': link_to(self.context.title, self.context.url()),
            'link_to_subject': link_to(self.subject.title, self.subject.url())}

    def shortened(self, context=True):
        if context:
            return "%(link_to_context)s > %(link_to_subject)s" % {
                'link_to_context': link_to(self.context.title, self.context.url(), 23),
                'link_to_subject': link_to(self.subject.title, self.subject.url(), 23)}
        else:
            return "%(link_to_subject)s" % {
                'link_to_subject': link_to(self.subject.title, self.subject.url(), 35)}


def setup_orm(engine):
    from ututi.model import files_table, pages_table, subjects_table
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
               properties = {'context': relation(ContentItem, backref=backref('events', cascade='save-update, merge, delete')),
                             'user': relation(User, backref='events')})

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

    orm.mapper(SubjectModifiedEvent, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='subject_modified')


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

    orm.mapper(GroupStartedWatchingSubjects, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='group_started_watching_subject',
               properties = {'subject': relation(Subject,
                                                 primaryjoin=subjects_table.c.id==events_table.c.subject_id)})

    orm.mapper(GroupStoppedWatchingSubjects, events_table,
               inherits=Event,
               polymorphic_on=events_table.c.event_type,
               polymorphic_identity='group_stopped_watching_subject',
               properties = {'subject': relation(Subject,
                                                 primaryjoin=subjects_table.c.id==events_table.c.subject_id)})


