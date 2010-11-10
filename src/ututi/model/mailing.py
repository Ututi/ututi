from rfc822 import AddressList
import mimetools
import time
from datetime import datetime
import email

from sqlalchemy.types import Unicode
from sqlalchemy.sql.expression import asc
from sqlalchemy.sql.expression import and_
from sqlalchemy.schema import Column
from sqlalchemy.schema import Table
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import backref
from sqlalchemy.orm import relation, synonym
from sqlalchemy import orm
from StringIO import StringIO

from pylons import config, url

from nous.mailpost.MailBoxerTools import splitMail, parseaddr

from ututi.model import ContentItem
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


def decode_and_join_header(header):
    from_parts = email.Header.decode_header(header)
    result = []
    for part in from_parts:
        if part[1]:
            result.append(part[0].decode(part[1]))
        else:
            result.append(part[0].decode('utf-8', 'ignore'))
    return u' '.join(result)


class UtutiEmail(email.message.Message):

    def getHeader(self, header):
        for key, value in self._headers:
            if key.lower() == header.lower():
                return value

    def getDate(self):
        date = self.getHeader('date')
        if date is None:
            return datetime.utcnow()
        return datetime.utcfromtimestamp(time.mktime(email.utils.parsedate(date)))

    def getMessageId(self):
        return self.getHeader('message-id')

    def getToAddresses(self):
        to_addrs = AddressList(self.getHeader('to')).addresslist
        cc_addrs = AddressList(self.getHeader('cc')).addresslist
        return to_addrs + cc_addrs

    def getFrom(self):
        return decode_and_join_header(self.getHeader("from"))

    def getSubject(self):
        subj = self.getHeader("subject")
        if subj:
            return decode_and_join_header(subj)
        else:
            from pylons.i18n import _
            return _('(no subject)')


def setup_orm(engine):
    from ututi.model import groups_table, content_items_table
    global group_mailing_list_messages_table
    group_mailing_list_messages_table = Table(
        "group_mailing_list_messages",
        meta.metadata,
        Column('subject', Unicode(assert_unicode=True)),
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
               inherits=ContentItem,
               polymorphic_identity='mailing_list_message',
               polymorphic_on=content_items_table.c.content_type,
               properties = {
                             'reply_to': relation(GroupMailingListMessage,
                                                  backref=backref('replies'),
                                                  foreign_keys=(columns.reply_to_group_id, columns.reply_to_message_id),
                                                  primaryjoin=and_(columns.group_id == columns.reply_to_group_id,
                                                                   columns.message_id == columns.reply_to_message_id),
                                                  remote_side=(columns.group_id,
                                                               columns.message_id)),
                             'thread': relation(GroupMailingListMessage,
                                                post_update=True,
                                                order_by=[asc(columns.sent)],
                                                backref=backref('posts'),
                                                foreign_keys=(columns.thread_group_id, columns.thread_message_id),
                                                primaryjoin=and_(columns.group_id == columns.thread_group_id,
                                                                 columns.message_id == columns.thread_message_id),
                                                remote_side=(columns.group_id,
                                                             columns.message_id)),
                             'author': relation(User,
                                                backref=backref('messages')),
                             'group': relation(Group,
                                               primaryjoin=(columns.group_id == groups_table.c.id)),
                             'attachments': synonym("files")
                             })


class GroupMailingListMessage(ContentItem):
    """Message in the group mailing list."""

    def info_dict(self):
        return {'thread_id': self.id,
                'last_reply_author_id': self.posts[-1].author,
                'last_reply_author_title': self.posts[-1].author.fullname,
                'last_reply_date': self.posts[-1].sent,
                'send': self.sent,
                'author': self.author,
                'body': self.body,
                'reply_count': len(self.posts) - 1,
                'subject': self.subject}

    def url(self):
        return self.group.url(controller='mailinglist', action='thread', thread_id=self.thread.id)

    @property
    def body(self):
        message = email.message_from_string(self.original, UtutiEmail)

        while message.is_multipart():
            message = message.get_payload()[0]

        charset = message.get_content_charset('utf-8')
        # fall back, in case we are being tricked
        if charset == 'us-ascii':
            charset = 'utf-8'
        payload = message.get_payload(decode=True)
        return payload.decode(charset)

    def getAuthor(self):
        author_name, author_address = parseaddr(self.mime_message['From'])
        return User.get(author_address)

    @property
    def mime_message(self):
        return mimetools.Message(StringIO(self.original))

    def send(self, recipients):
        footer = ""
        for attachment in self.attachments:
            # XXX can't decide whether this belongs in the model or in
            # the controller, maybe we should have a template, and
            # pass it to this method?
            attachment_url = attachment.url(qualified=True)
            if attachment.title == 'text.html':
                continue
            footer += '\n%s - %s' % (attachment.title, attachment_url)

        message = email.message_from_string(self.original, UtutiEmail)

        address = "%s@%s" % (self.group.group_id,
                             config.get('mailing_list_host'))

        try:
            message.replace_header('Reply-To', address)
        except KeyError:
            message.add_header('Reply-To', address)
        message.add_header('Errors-To', config.get('email_to', 'errors@ututi.lt'))
        message.add_header('List-Id', address)

        if footer:
            payload = self.body + footer
            payload = payload.encode('utf-8')
            if message.is_multipart():
                original_payload = message.get_payload()[0]
                original_payload._headers = []
                original_payload.set_payload(payload, charset='utf-8')
            else:
                message.set_payload(payload, charset='utf-8')

        raw_send_email(self.mime_message['From'],
                       recipients,
                       message.as_string())

    @classmethod
    def fromMessageText(cls, message_text):
        message = email.message_from_string(message_text, UtutiEmail)
        message_id = message.getMessageId()

        mailing_list_host = config.get('mailing_list_host')
        mailing_list_hosts = [mailing_list_host,
                              'lists.ututi.lt']

        group_ids = []
        for name, address in message.getToAddresses():
            if '@' not in address:
                continue
            prefix, suffix = address.split('@')
            if suffix in mailing_list_hosts:
                group_ids.append(prefix)

        g = None
        if group_ids:
            for group_id in group_ids:
                g = Group.get(group_id)
                if g is not None:
                    break

        #use the numerical group id
        if g is not None:
            group_id = g.id
        else:
            from pylons.controllers.util import abort
            abort(404)

        if cls.get(message_id, group_id):
            raise MessageAlreadyExists(message_id, group_id)

        reply_to_message_id = message.getHeader('in-reply-to')
        reply_to = cls.get(reply_to_message_id, group_id)

        # XXX Hacky way to find messages this message might be a reply to
        if not reply_to:
            sbj = message.getSubject()
            parts = sbj.split(':')
            if len(parts) > 1:
                real_sbj = parts[-1].strip()
                reply_to = meta.Session.query(cls).filter_by(subject=real_sbj,
                                                             group_id=group_id).first()
        return cls(message_text,
                   message_id,
                   group_id,
                   message.getSubject(),
                   message.getDate(),
                   reply_to)

    @classmethod
    def get(cls, message_id, group_id):
        try:
            g = Group.get(group_id)
            if g is None:
                return None #??? is the way it is supposed to be?
            return meta.Session.query(cls).filter_by(message_id=message_id,
                                                     group_id=g.id).one()
        except NoResultFound:
            return None

    def __init__(self,
                 message_text,
                 message_id,
                 group_id,
                 subject,
                 sent,
                 reply_to=None):
        self.original = message_text
        self.author = self.getAuthor()
        self.message_id = message_id
        self.subject = subject
        self.sent = sent
        self.group_id = group_id
        self.reply_to = reply_to
        self.body
