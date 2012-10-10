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

from pylons import config

from nous.mailpost.MailBoxerTools import parseaddr

from ututi.model import ContentItem
from ututi.model import Group
from ututi.model import meta, User
from ututi.model.users import AnonymousUser
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

    def getAuthor(self):
        author_name, author_address = parseaddr(self.getHeader("from"))
        return User.get_global(author_address)

    def getBody(self):
        message = self
        while message.is_multipart():
            message = message.get_payload()[0]

        charset = message.get_content_charset('utf-8')
        # fall back, in case we are being tricked
        if charset == 'us-ascii':
            charset = 'utf-8'
        payload = message.get_payload(decode=True)
        return payload.decode(charset)

    def getGroup(self):
        mailing_list_host = config.get('mailing_list_host')
        mailing_list_hosts = [mailing_list_host,
                              'lists.ututi.lt',
                              'groups.ututi.lt']

        group_ids = []
        for name, address in self.getToAddresses():
            if '@' not in address:
                continue
            prefix, suffix = address.split('@')
            if suffix in mailing_list_hosts:
                group_ids.append(prefix)

        # XXX what if I CC message to 2 groups at the same time?
        g = None
        if group_ids:
            for group_id in group_ids:
                g = Group.get(group_id)
                if g is not None:
                    break
        return g

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

def setup_tables(engine):
    global group_mailing_list_messages_table
    group_mailing_list_messages_table = Table(
        "group_mailing_list_messages",
        meta.metadata,
        Column('subject', Unicode()),
        autoload=True,
        autoload_with=engine,
        useexisting=True)
    global group_mailing_list_attachments_table
    group_mailing_list_attachments_table = Table(
        "group_mailing_list_attachments",
        meta.metadata,
        autoload=True,
        autoload_with=engine)


def setup_orm():
    tables = meta.metadata.tables
    columns = tables['group_mailing_list_messages'].c
    orm.mapper(GroupMailingListMessage,
               tables['group_mailing_list_messages'],
               inherits=ContentItem,
               polymorphic_identity='mailing_list_message',
               polymorphic_on=tables['content_items'].c.content_type,
               properties = {
                             'reply_to': relation(GroupMailingListMessage,
                                                  backref=backref('replies'),
                                                  foreign_keys=(columns.reply_to_message_machine_id),
                                                  primaryjoin=columns.id == columns.reply_to_message_machine_id,
                                                  remote_side=(columns.id)),
                             'thread': relation(GroupMailingListMessage,
                                                post_update=True,
                                                order_by=[asc(columns.sent)],
                                                backref=backref('posts'),
                                                foreign_keys=(columns.thread_message_machine_id),
                                                primaryjoin=columns.id == columns.thread_message_machine_id,
                                                remote_side=(columns.id)),
                             'author': relation(User,
                                                backref=backref('messages')),
                             'group': relation(Group,
                                               primaryjoin=(columns.group_id == tables['groups'].c.id)),
                             'attachments': synonym("files")
                             })


class GroupMailingListMessage(ContentItem):
    """Message in the group mailing list."""

    def info_dict(self):
        return {'thread_id': self.id,
                'send': self.sent,
                'author': {'title': self.author_or_anonymous.fullname,
                           'url': self.author_or_anonymous.url()},
                'body': self.body,
                'reply_count': len(self.posts) - 1,
                'subject': self.subject}

    @property
    def author_or_anonymous(self):
        if self.author:
            return self.author
        else:
            name, email = parseaddr(decode_and_join_header(self.mime_message['From']))
            return AnonymousUser(name, email)

    def url(self, action=None):
        if self.in_moderation_queue:
            if action == None:
                action = 'moderate_post'
            thread_id = self.id
        else:
            if action == None:
                action = 'thread'
            thread_id = self.thread.id
        return self.group.url(controller='mailinglist', action=action, thread_id=thread_id)

    @property
    def body(self):
        message = email.message_from_string(self.original, UtutiEmail)
        return message.getBody()

    def getAuthor(self):
        author_name, author_address = parseaddr(self.mime_message['From'])
        return User.get_global(author_address)

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

        if not message.getHeader('Errors-To'):
            message.add_header('Errors-To', config.get('email_to', 'errors@ututi.lt'))
        if not message.getHeader('List-Id'):
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
    def parseMessage(cls, message_text):
        return email.message_from_string(message_text, UtutiEmail)

    @classmethod
    def fromMessageText(cls, message_text, force=False):
        message = cls.parseMessage(message_text)
        message_id = message.getMessageId()
        g = message.getGroup()

        #use the numerical group id
        if g is None:
            return

        group_id = g.id

        if cls.get(message_id, group_id):
            raise MessageAlreadyExists(message_id, group_id)

        mime_message = mimetools.Message(StringIO(message_text))
        author_name, author_address = parseaddr(mime_message['From'])
        author = User.get_global(author_address)
        in_moderation_queue = False

        whitelist = [i.email for i in g.whitelist] + [
            config.get('ututi_email_from', 'info@ututi.pl')]
        if not (author_address in whitelist or
                author is not None and g.is_member(author)
                or force):
            if g.mailinglist_moderated:
                in_moderation_queue = True
            else:
                return # Bounce

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
                   reply_to,
                   in_moderation_queue)

    @classmethod
    def get(cls, message_id, group_id):
        try:
            g = Group.get(group_id)
            if g is None:
                return None #??? is the way it is supposed to be?
            if isinstance(message_id, (long, int)):
                return meta.Session.query(cls).filter_by(id=message_id,
                                                         group_id=g.id).one()

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
                 reply_to=None,
                 in_moderation_queue=False):
        self.in_moderation_queue = in_moderation_queue
        self.original = message_text
        self.author = self.getAuthor()
        self.message_id = message_id
        self.subject = subject
        self.sent = sent
        self.group_id = group_id
        self.reply_to = reply_to
        self.body

    def approve(self):
        self.in_moderation_queue = False
        author_name, author_address = parseaddr(self.mime_message['From'])
        self.group.add_email_to_whitelist(author_address)
        from ututi.model.events import ModeratedPostCreated
        event = meta.Session.query(ModeratedPostCreated).filter_by(message_id=self.id).one()
        meta.Session.delete(event)
        meta.Session.commit()
        self.send(self.group.recipients_mailinglist())

    def reject(self):
        meta.Session.delete(self)
