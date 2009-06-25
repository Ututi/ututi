import mimetools
from sqlalchemy.schema import Table
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import backref
from sqlalchemy.orm import relation
from sqlalchemy import orm
from StringIO import StringIO

from routes.util import url_for

from nous.mailpost.MailBoxerTools import splitMail, parseaddr

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
    global group_mailing_list_messages_table
    group_mailing_list_messages_table = Table(
        "group_mailing_list_messages",
        meta.metadata,
        autoload=True,
        autoload_with=engine)
    orm.mapper(GroupMailingListMessage,
               group_mailing_list_messages_table,
               properties = {'replies' : relation(GroupMailingListMessage,
                                                  backref=backref('reply_to'),
                                                  remote_side = (group_mailing_list_messages_table.c.reply_to_group_id,
                                                                 group_mailing_list_messages_table.c.reply_to_message_id)),
                             'author' : relation(User,
                                                 backref=backref('messages'))
                             })

    global group_mailing_list_attachments_table
    group_mailing_list_attachments_table = Table(
        "group_mailing_list_attachments",
        meta.metadata,
        autoload=True,
        autoload_with=engine)
    orm.mapper(GroupMailingListAttachment, group_mailing_list_attachments_table,
               properties = {'message' : relation(GroupMailingListMessage,
                                                  backref=backref('attachments')),
                             'file' : relation(File)})


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
        headers_dict, body = splitMail(self.original.encode("utf-8"))
        headers = "".join(self.mime_message.headers)

        footer = ""
        for attachment in self.attachments:
            # XXX can't decide whether this belongs in the model or in
            # the controller, maybe we should have a template, and
            # pass it to this method?
            url = url_for(controller='files', action='get', id=attachment.file.id,
                          qualified=True)
            footer += '<a href="%s">%s</a>' % (url, attachment.file.title)
        new_message = "%s\r\n%s\r\n%s" % (headers, body, footer)
        raw_send_email(self.mime_message['From'],
                       recipients,
                       new_message)

    @classmethod
    def fromMessageText(cls, message_text):
        headers_dict, body = splitMail(message_text.encode("utf-8"))
        message_id = headers_dict['message-id']
        group_id = "moderators"
        if cls.get(message_id, group_id):
            raise MessageAlreadyExists(message_id, group_id)
        return cls(message_text, message_id, group_id)

    @classmethod
    def get(cls, message_id, group_id):
        try:
            return meta.Session.query(cls).filter_by(message_id=message_id,
                                                     group_id=group_id).one()
        except NoResultFound:
            return None

    def __init__(self, message_text, message_id, group_id):
        self.original = message_text
        self.author = self.getAuthor()
        self.message_id = message_id
        self.group_id = group_id


class GroupMailingListAttachment(object):
    """Attachment for group mailing list messages."""
