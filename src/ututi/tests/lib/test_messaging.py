from datetime import date

import doctest

import pylons.test
from pylons import config

import ututi

from ututi.tests import UtutiLayer
from ututi.lib.messaging import EmailMessage, GGMessage, SMSMessage
from ututi.model import User, Group, Email, SMS, meta
from ututi.model import GroupMembershipType, GroupMember, LocationTag
from ututi.lib.mailer import mail_queue
from ututi.lib.gg import sent_messages as gg_queue

def test_message_user():
    """Tests for messaging.

        >>> config._push_object(pylons.test.pylonsapp.config)

        >>> user = User.get("somebloke@somehost.com", LocationTag.get('uni'))
        >>> group = meta.Session.query(Group).first()

        >>> msg = EmailMessage("the subject", "the text")

    If the user does not have a confirmed email address, the message should not be sent.

        >>> msg.send(user)

    Unless it is forced:

        >>> msg.force = True
        >>> msg.send(user)
        >>> print mail_queue.pop().message
        MIME-Version: 1.0
        Content-Type: text/plain; charset="us-ascii"
        Content-Transfer-Encoding: 7bit
        From: info@ututi.lt
        To: somebloke@somehost.com
        Subject: the subject
        <BLANKLINE>
        the text

    EmailMessages can also be sent the other way around:
        >>> user.send(msg)
        >>> print mail_queue.pop().message
        MIME-Version: 1.0
        Content-Type: text/plain; charset="us-ascii"
        Content-Transfer-Encoding: 7bit
        From: info@ututi.lt
        To: somebloke@somehost.com
        Subject: the subject
        <BLANKLINE>
        the text

        >>> config._pop_object(pylons.test.pylonsapp.config)
    """


def test_message_attachments():
    """Tests for email attachments

        >>> config._push_object(pylons.test.pylonsapp.config)
        >>> import cStringIO

        >>> msg = EmailMessage("the subject", 'The contents of the file.', attachments=[{'filename': 'file.txt', 'file':cStringIO.StringIO('the content')}])

        >>> msg.send('someemail@somehost.lt')

        >>> print mail_queue.pop().message
        Content-Type: multipart/mixed; boundary="===============...=="
        MIME-Version: 1.0
        From: info@ututi.lt
        To: someemail@somehost.lt
        Subject: the subject
        <BLANKLINE>
        This is a multi-part message in MIME format.
        --===============...==
        Content-Type: multipart/alternative;
        	boundary="===============...=="
        MIME-Version: 1.0
        Content-Disposition: inline
        <BLANKLINE>
        --===============...==
        MIME-Version: 1.0
        Content-Type: text/plain; charset="us-ascii"
        Content-Transfer-Encoding: 7bit
        <BLANKLINE>
        The contents of the file.
        --===============...==--
        --===============...==
        Content-Type: application/octet-stream
        MIME-Version: 1.0
        Content-Transfer-Encoding: base64
        Content-Disposition: attachment; filename="file.txt"
        <BLANKLINE>
        dGhlIGNvbnRlbnQ=
        --===============...==--
        >>> config._pop_object(pylons.test.pylonsapp.config)

    """


def test_ggmessage_user():
    """Tests for gadugadu messaging.

        >>> config._push_object(pylons.test.pylonsapp.config)

        >>> user = User.get("somebloke@somehost.com", LocationTag.get('uni'))

        >>> msg = GGMessage("the message")

    If the user does not have a confirmed email address, the message should not be sent.

        >>> msg.send(user)
        >>> len(gg_queue)
        0

    Unless it is forced:

        >>> msg.force = True
        >>> msg.send(user)
        >>> print gg_queue.pop()
        (345665L, 'the message')

        >>> config._pop_object(pylons.test.pylonsapp.config)

    """

def test_smsmessage_user():
    """Tests for sms messaging.

        >>> config._push_object(pylons.test.pylonsapp.config)

        >>> user = User.get("somebloke@somehost.com", LocationTag.get('uni'))

        >>> msg = SMSMessage(u"the message", sender=user)

    If the user does not have a confirmed phone number, the message should not be sent.

        >>> msg.send(user)
        >>> meta.Session.commit()
        >>> len(meta.Session.query(SMS).all())
        0

    Unless it is forced:

        >>> msg.force = True
        >>> msg.send(user)
        >>> meta.Session.commit()

        >>> sms = meta.Session.query(SMS).first()
        >>> print (sms.recipient_number, sms.message_text)
        ('+37060000000', u'the message')

        >>> config._pop_object(pylons.test.pylonsapp.config)
        >>> from ututi.lib.sms import sms_queue
        >>> sms_queue.pop()
        ('+37060000000', u'the message')

    """


def test_message_list():
    """Sending messages to lists of recipients.

        >>> config._push_object(pylons.test.pylonsapp.config)

    This can be a list of emails.

        >>> msg = EmailMessage("the subject", "the text", ignored_recipients=["ignored@example.com"])
        >>> msg.send(["email@host.com", "email2@example.com", "invalidemail", "ignored@example.com"])

    One recipient is invalid, one is ignored, so only two emails should be left.

        >>> print mail_queue.pop().message
        MIME-Version: 1.0
        Content-Type: text/plain; charset="us-ascii"
        Content-Transfer-Encoding: 7bit
        From: info@ututi.lt
        To: email2@example.com
        Subject: the subject
        <BLANKLINE>
        the text

        >>> print mail_queue.pop().message
        MIME-Version: 1.0
        Content-Type: text/plain; charset="us-ascii"
        Content-Transfer-Encoding: 7bit
        From: info@ututi.lt
        To: email@host.com
        Subject: the subject
        <BLANKLINE>
        the text

        >>> config._pop_object(pylons.test.pylonsapp.config)

    """

def test_message_group():
    """ Try sending emails to a group.

        >>> config._push_object(pylons.test.pylonsapp.config)

        >>> g = Group.get("moderators")
        >>> msg = EmailMessage("the subject", "the text")
        >>> msg.send(g)
        >>> print mail_queue.pop().message
        MIME-Version: 1.0
        Content-Type: text/plain; charset="us-ascii"
        Content-Transfer-Encoding: 7bit
        From: info@ututi.lt
        To: admin@uni.ututi.com
        Subject: the subject
        <BLANKLINE>
        the text

        >>> config._pop_object(pylons.test.pylonsapp.config)

    """

def test_setup(test):
    """Create some models for this test."""
    ututi.tests.setUp(test)

    # The following c&p from model tests. Maybe should be put to base set up.

    #a user needs a university
    uni = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    meta.Session.add(uni)
    meta.Session.commit()

    #the user
    meta.Session.execute("insert into authors (type, fullname) values ('user', 'Administrator of the university')")
    meta.Session.execute("insert into users (id, location_id, username, password)"
                         " (select authors.id, tags.id, 'admin@uni.ututi.com', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7'"
                         " from tags, authors where title_short = 'uni' and fullname = 'Administrator of the university');")
    meta.Session.execute("insert into emails (id, email, confirmed)"
                         " (select users.id, users.username, true from users where username = 'admin@uni.ututi.com')")
    meta.Session.commit()

    u = User.get('admin@uni.ututi.com', uni)
    user = User(u"a new user", "somebloke@somehost.com", uni, "his password")
    meta.Session.add(user)
    user.emails.append(Email("somebloke@somehost.com"))
    user.gadugadu_uin = '345665'
    user.gadugadu_confirmed = False
    user.phone_number = '+37060000000'
    user.phone_confirmed = False
    meta.Session.commit()

    meta.Session.execute("SET LOCAL ututi.active_user TO %d" % u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')

    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)
    meta.Session.commit()
    meta.set_active_user(u.id)


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = UtutiLayer
    return suite

