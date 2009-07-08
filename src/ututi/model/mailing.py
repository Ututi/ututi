import mimetools
from sqlalchemy.sql.expression import and_
from sqlalchemy.schema import Table
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import backref
from sqlalchemy.orm import relation
from sqlalchemy import orm
from StringIO import StringIO

from routes.util import url_for

from nous.mailpost.MailBoxerTools import splitMail, parseaddr

from ututi.model import Group
from ututi.model import meta, User, File
from ututi.lib.mailer import raw_send_email


class MessageAlreadyExists(Exception):
    """Exception raised when someone tries to create a message already in the database.

    We check for the message_id and group_id before creating the
    actual message class to prevent errors in unexpected places.
    """


group_mailing_list_messages_table = None
group_mailing_list_attachments_table = None


def setup_orm(engine):
    from ututi.model import groups_table
    global group_mailing_list_messages_table
    group_mailing_list_messages_table = Table(
        "group_mailing_list_messages",
        meta.metadata,
        autoload=True,
        autoload_with=engine)
    global group_mailing_list_attachments_table
    group_mailing_list_attachments_table = Table(
        "group_mailing_list_attachments",
        meta.metadata,
        autoload=True,
        autoload_with=engine)
    columns = group_mailing_list_messages_table.c
    orm.mapper(GroupMailingListMessage,
               group_mailing_list_messages_table,
               properties = {
                             'reply_to' : relation(GroupMailingListMessage,
                                                   backref=backref('replies'),
                                                   foreign_keys=(columns.reply_to_group_id, columns.reply_to_message_id),
                                                   primaryjoin=and_(columns.group_id == columns.reply_to_group_id,
                                                                    columns.message_id == columns.reply_to_message_id),
                                                   remote_side=(columns.group_id,
                                                                columns.message_id)),
                             'thread' : relation(GroupMailingListMessage,
                                                 post_update=True,
                                                 backref=backref('posts'),
                                                 foreign_keys=(columns.thread_group_id, columns.thread_message_id),
                                                 primaryjoin=and_(columns.group_id == columns.thread_group_id,
                                                                  columns.message_id == columns.thread_message_id),
                                                 remote_side=(columns.group_id,
                                                              columns.message_id)),
                             'author' : relation(User,
                                                 backref=backref('messages')),
                             'group' : relation(Group,
                                                primaryjoin=(columns.group_id == groups_table.c.id)),
                             'attachments': relation(File,
                                                     secondary=group_mailing_list_attachments_table)
                             })


class GroupMailingListMessage(object):
    """Message in the group mailing list."""

    @property
    def body(self):
        headers_dict, body = splitMail(self.original.encode("utf-8"))
        return body

    def getAuthor(self):
        author_name, author_address = parseaddr(self.mime_message['From'])
        return User.get(author_address)

    @property
    def mime_message(self):
        return mimetools.Message(StringIO(self.original))

    def send(self, recipients):
        headers_dict, body = splitMail(self.original)
        headers = "".join(self.mime_message.headers)

        footer = ""
        for attachment in self.attachments:
            # XXX can't decide whether this belongs in the model or in
            # the controller, maybe we should have a template, and
            # pass it to this method?
            url = url_for(controller='files', action='get', id=attachment.id,
                          qualified=True)
            footer += '<a href="%s">%s</a>' % (url, attachment.title)
        new_message = "%s\r\n%s\r\n%s" % (headers, body, footer)
        raw_send_email(self.mime_message['From'],
                       recipients,
                       new_message)

    @classmethod
    def fromMessageText(cls, message_text):
        headers_dict, body = splitMail(message_text.encode("utf-8"))
        message_id = headers_dict['message-id']
        subject = headers_dict['subject']
        group_id = headers_dict["to"].split("@")[0]
        if cls.get(message_id, group_id):
            raise MessageAlreadyExists(message_id, group_id)

        reply_to_message_id = headers_dict.get('in-reply-to', None)
        reply_to = cls.get(reply_to_message_id, group_id)

        return cls(message_text, message_id, group_id, subject, reply_to)

    @classmethod
    def get(cls, message_id, group_id):
        try:
            return meta.Session.query(cls).filter_by(message_id=message_id,
                                                     group_id=group_id).one()
        except NoResultFound:
            return None

    def __init__(self, message_text, message_id, group_id, subject, reply_to=None):
        self.original = message_text
        self.author = self.getAuthor()
        self.message_id = message_id
        self.subject = subject
        self.group_id = group_id
        self.reply_to = reply_to
