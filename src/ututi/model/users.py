import logging
from pylons import url
from sqlalchemy.sql.expression import desc
from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import func
from sqlalchemy.sql.expression import and_
from sqlalchemy.orm.exc import NoResultFound
from random import randrange
from binascii import a2b_base64, b2a_base64
import binascii
import urllib
import hashlib
from datetime import datetime


from ututi.model.util import logo_property
from ututi.model import meta
from ututi.lib.helpers import image

from pylons.i18n import _
from pylons import config

log = logging.getLogger(__name__)


class UserSubjectMonitoring(object):
    """Relationship between user and subject."""
    def __init__(self, user, subject, ignored=False):
        self.user, self.subject, self.ignored = user, subject, ignored


def generate_salt():
    """Generate the salt used in passwords."""
    salt = ''
    for n in range(7):
        salt += chr(randrange(256))
    return salt


def generate_password(password):
    """Generate a hash for a given password."""
    salt = generate_salt()
    password = password.encode('utf-8')
    return b2a_base64(hashlib.sha1(password + salt).digest() + salt)[:-1]


def validate_password(reference, password):
    """Verify a password given the original hash."""
    if not reference:
        return False
    try:
        ref = a2b_base64(reference)
    except binascii.Error:
        return False
    salt = ref[20:]
    compare = b2a_base64(hashlib.sha1(password + salt).digest() + salt)[:-1]
    return compare == reference


class AdminUser(object):

    @classmethod
    def authenticate(cls, username, password):
        user = cls.get(username)
        if user is None:
            return None
        if validate_password(user.password, password):
            return user
        else:
            return None

    @classmethod
    def get(cls, username):
        """Get a user by his email or id."""
        try:
            if isinstance(username, (long, int)):
                return meta.Session.query(cls).filter_by(id=username).one()
            else:
                return meta.Session.query(cls).filter_by(email=username.strip().lower()).one()
        except NoResultFound:
            return None


class User(object):
    """The User object - Ututi users."""
    is_teacher = False

    def change_type(self, type, **kwargs):
        from ututi.model import users_table
        conn = meta.engine.connect()
        upd = users_table.update().where(users_table.c.id==id).values(user_type=type, **kwargs)
        conn.execute(upd)

    @property
    def email(self):
        email = self.emails[0]
        return email

    @property
    def hidden_blocks_list(self):
        return self.hidden_blocks.strip().split(' ')

    def send(self, msg):
        """Send a message to the user."""
        from ututi.lib.messaging import EmailMessage, GGMessage, SMSMessage
        if isinstance(msg, EmailMessage):
            email = self.emails[0]
            if email.confirmed or msg.force:
                msg.send(email.email)
            else:
                log.info("Could not send message to unconfirmed email %(email)s" % dict(email=email.email))
        elif isinstance(msg, GGMessage):
            if self.gadugadu_confirmed or msg.force:
                msg.send(self.gadugadu_uin)
            else:
                log.info("Could not send message to unconfirmed gadugadu account %(gg)s" % dict(gg=self.gadugadu_uin))
        elif isinstance(msg, SMSMessage):
            if self.phone_number is not None and (self.phone_confirmed or msg.force):
                msg.recipient=self
                msg.send(self.phone_number)
            else:
                log.info("Could not send message to uncofirmed phone number %(num)s" % dict(num=self.phone_number))

    def checkPassword(self, password):
        """Check the user's password."""
        return validate_password(self.password, password)

    def files(self):
        from ututi.model import ContentItem
        return meta.Session.query(ContentItem).filter_by(
                content_type='file', created=self, deleted_by=None).all()

    def files_count(self):
        from ututi.model import ContentItem
        return meta.Session.query(ContentItem).filter_by(
                content_type='file', created=self, deleted_by=None).count()

    def group_requests(self):
        from ututi.model import PendingRequest, Group, GroupMember
        return meta.Session.query(PendingRequest
                ).join(Group).join(GroupMember
                ).filter(GroupMember.user == self
                ).filter(GroupMember.membership_type == 'administrator'
                ).all()

    @classmethod
    def authenticate(cls, location, username, password):
        user = cls.get(username, location)
        if user is None:
            return None
        if validate_password(user.password, password):
            return user
        else:
            return None

    @classmethod
    def authenticate_global(cls, username, password):
        user = cls.get_global(username)
        if user is None:
            return None
        if validate_password(user.password, password):
            return user
        else:
            return None

    @classmethod
    def get(cls, username, location):
        q = meta.Session.query(cls)

        try:
            if isinstance(username, (long, int)):
                q = q.filter_by(id=username)
            else:
                q = q.filter_by(username=username.strip().lower())
            if isinstance(location, (long, int)):
                q = q.filter_by(location_id=location)
            else:
                q = q.filter_by(location_id=location.id)
            return q.one()
        except NoResultFound:
            return None

    @classmethod
    def get_global(cls, username):
        """Get a user by his email or id."""
        try:
            if isinstance(username, (long, int)):
                return meta.Session.query(cls).filter_by(id=username).one()
            else:
                return meta.Session.query(cls).filter_by(username=username.strip().lower()).one()
        except NoResultFound:
            return None

    @classmethod
    def get_byid(cls, id, location=None):
        q = meta.Session.query(cls)
        try:
            q = q.filter_by(id=id)
            if location is not None:
                q = q.filter_by(location_id=location.id)
            return q.one()
        except NoResultFound:
            return None

    @classmethod
    def get_byopenid(cls, openid, location=None):
        q = meta.Session.query(cls)
        try:
            q = q.filter_by(openid=openid)
            if location is not None:
                q = q.filter_by(location_id=location.id)
            return q.one()
        except NoResultFound:
            return None

    @classmethod
    def get_byfbid(cls, facebook_id, location=None):
        q = meta.Session.query(cls)
        try:
            q = q.filter_by(facebook_id=facebook_id)
            if location is not None:
                q = q.filter_by(location_id=location.id)
            return q.one()
        except NoResultFound:
            return None

    @classmethod
    def get_byphone(cls, phone_number):
        try:
            return meta.Session.query(cls).filter_by(
                    phone_number=phone_number, phone_confirmed=True).one()
        except NoResultFound:
            return None

    def confirm_phone_number(self):
        # If there is another user with the same number, mark his phone
        # as unconfirmed.  This way there is only one person with a specific
        # confirmed phone number at any time.
        other = User.get_byphone(self.phone_number)
        if other is not None:
            other.phone_confirmed = False
        self.phone_confirmed = True

    @property
    def ignored_subjects(self):
        from ututi.model import user_monitored_subjects_table
        from ututi.model import Subject
        from ututi.model import subjects_table
        umst = user_monitored_subjects_table
        user_ignored_subjects = meta.Session.query(Subject)\
            .join((umst,
                   and_(umst.c.subject_id==subjects_table.c.id,
                        umst.c.subject_id==subjects_table.c.id)))\
            .filter(and_(umst.c.user_id == self.id,
                         umst.c.ignored == True))
        return user_ignored_subjects.all()

    @property
    def watched_subjects(self):
        from ututi.model import user_monitored_subjects_table, subjects_table
        from ututi.model import Subject
        umst = user_monitored_subjects_table
        directly_watched_subjects = meta.Session.query(Subject)\
            .join((umst,
                   and_(umst.c.subject_id==subjects_table.c.id,
                        umst.c.subject_id==subjects_table.c.id)))\
            .filter(and_(umst.c.user_id == self.id,
                         umst.c.ignored == False))
        return directly_watched_subjects.all()

    @property
    def all_watched_subjects(self):
        from ututi.model import user_monitored_subjects_table, subjects_table
        from ututi.model import Subject
        umst = user_monitored_subjects_table
        directly_watched_subjects = meta.Session.query(Subject)\
            .join((umst,
                   and_(umst.c.subject_id==subjects_table.c.id,
                        umst.c.subject_id==subjects_table.c.id)))\
            .filter(and_(umst.c.user_id == self.id,
                         umst.c.ignored == False))

        user_ignored_subjects = meta.Session.query(Subject)\
            .join((umst,
                   and_(umst.c.subject_id==subjects_table.c.id,
                        umst.c.subject_id==subjects_table.c.id)))\
            .filter(and_(umst.c.user_id == self.id,
                         umst.c.ignored == True))

        from ututi.model import group_watched_subjects_table, group_members_table, groups_table
        gwst = group_watched_subjects_table
        gmt = group_members_table
        gt = groups_table
        group_watched_subjects = meta.Session.query(Subject)\
            .join((gwst,
                   and_(gwst.c.subject_id==subjects_table.c.id,
                        gwst.c.subject_id==subjects_table.c.id)))\
            .join((gmt, gmt.c.group_id == gwst.c.group_id))\
            .join((gt, gmt.c.group_id == gt.c.id))\
            .filter(gmt.c.user_id == self.id)
        return directly_watched_subjects.union(
            group_watched_subjects.except_(user_ignored_subjects))\
            .order_by(Subject.title.asc())\
            .all()

    def _setWatchedSubject(self, subject, ignored):
        usm = meta.Session.query(UserSubjectMonitoring)\
            .filter_by(user=self, subject=subject, ignored=ignored).first()
        if usm is None:
            usm = UserSubjectMonitoring(self, subject, ignored=ignored)
            meta.Session.add(usm)

    def _unsetWatchedSubject(self, subject, ignored):
        usm = meta.Session.query(UserSubjectMonitoring)\
            .filter_by(user=self, subject=subject, ignored=ignored).first()
        if usm is not None:
            meta.Session.delete(usm)

    def watchSubject(self, subject):
        self._setWatchedSubject(subject, ignored=False)

    def unwatchSubject(self, subject):
        self._unsetWatchedSubject(subject, ignored=False)

    def ignoreSubject(self, subject):
        self._setWatchedSubject(subject, ignored=True)

    def unignoreSubject(self, subject):
        self._unsetWatchedSubject(subject, ignored=True)

    def url(self, controller='user', action='index', **kwargs):
        return url(controller=controller,
                   action=action,
                   id=self.id,
                   **kwargs)

    def watches(self, subject):
        return subject in self.watched_subjects

    @property
    def groups(self):
        from ututi.model import Group
        from ututi.model import GroupMember
        return meta.Session.query(Group).join(GroupMember).order_by(Group.title.asc()).filter(GroupMember.user == self).all()

    @property
    def groups_uploadable(self):
        from ututi.model import Group
        from ututi.model import GroupMember
        return meta.Session.query(Group).join(GroupMember).filter(GroupMember.user == self)\
            .filter(Group.has_file_area == True).all()

    def all_medals(self):
        """Return a list of medals for this user, including implicit medals."""
        from ututi.model import GroupMember, Payment
        from ututi.model import GroupMembershipType
        is_moderator = bool(meta.Session.query(GroupMember
            ).filter_by(user=self, role=GroupMembershipType.get('moderator')
            ).count())
        is_admin = bool(meta.Session.query(GroupMember
            ).filter_by(user=self, role=GroupMembershipType.get('administrator')
            ).count())
        is_supporter = bool(meta.Session.query(Payment
            ).filter_by(user=self, payment_type='support'
            ).filter_by(raw_error='').count())

        implicit_medals = {'support': is_moderator,
                           'admin': is_admin,
                           'buyer': is_supporter}

        medals = list(self.medals)

        def has_medal(medal_type):
            for medal in medals:
                if medal.medal_type == medal_type:
                    return True
            else:
                return False

        for medal_type, test_f in implicit_medals.items():
            if test_f and not has_medal(medal_type):
                medals.append(ImplicitMedal(self, medal_type))
        order = [m[0] for m in Medal.available_medals()]
        medals.sort(key=lambda m: order.index(m.medal_type))
        return medals

    def __init__(self, fullname, username, location, password, gen_password=True):
        self.fullname = fullname
        self.location = location
        self.username = username
        self.update_password(password, gen_password)

    def update_password(self, password, gen_password=True):
        if gen_password:
            self.password = generate_password(password)
        else:
            self.password = password

    def update_logo_from_facebook(self):
        if self.logo:
            return # Never overwrite a custom logo.
        if not self.facebook_id:
            return
        photo_url = 'https://graph.facebook.com/%s/picture?type=large' % self.facebook_id
        try:
            logo = urllib.urlopen(photo_url).read()
        except IOError:
            pass
        else:
            try:
                self.logo = logo
            except IOError:
                pass

    def download(self, file, range_start=None, range_end=None):
        from ututi.model import FileDownload
        self.downloads.append(FileDownload(self, file, range_start, range_end))

    def download_count(self):
        from ututi.model import FileDownload
        download_count = meta.Session.query(FileDownload)\
            .filter(FileDownload.user==self)\
            .filter(FileDownload.range_start==None)\
            .filter(FileDownload.range_end==None).count()
        return download_count

    def download_size(self):
        from ututi.model import File, FileDownload
        download_size = meta.Session.query(func.sum(File.filesize))\
            .filter(FileDownload.file_id==File.id)\
            .filter(FileDownload.user==self)\
            .filter(FileDownload.range_start==None)\
            .filter(FileDownload.range_end==None)\
            .scalar()
        if not download_size:
            return 0
        return int(download_size)

    @property
    def isConfirmed(self):
        return self.emails[0].confirmed

    logo = logo_property()

    def has_logo(self):
        return bool(meta.Session.query(User).filter_by(id=self.id).filter(User.raw_logo != None).count())

    def unread_messages(self):
        from ututi.model import PrivateMessage
        return meta.Session.query(PrivateMessage).filter_by(recipient=self, is_read=False).count()

    def unread_feed_messages(self):
        from ututi.model.events import Event
        from pylons import tmpl_context as c

        events = meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id for s in c.user.all_watched_subjects]),
                        Event.object_id.in_([m.group.id for m in c.user.memberships])))\
            .filter(Event.author_id != c.user.id)\
            .order_by(desc(Event.created))\
            .limit(20).all()

        count = 0

        for event in events:
            if event.created > c.user.last_seen_feed:
                count += 1

        return count

    def purchase_sms_credits(self, credits):
        self.sms_messages_remaining += credits
        log.info("user %(id)d (%(fullname)s) purchased %(credits)s credits; current balance: %(current)d credits." % dict(id=self.id, fullname=self.fullname, credits=credits, current=self.sms_messages_remaining))

    def can_send_sms(self, group):
        return self.sms_messages_remaining > len(group.recipients_sms(sender=self))

    @property
    def ignored_events_list(self):
        return self.ignored_events.split(',')

    def update_ignored_events(self, events):
        self.ignored_events = ','.join(list(set(events)))


class AnonymousUser(object):
    """Helper class for dealing with anonymous users. No ORM."""

    def __init__(self, name=None, email=None):
        self.name = name
        self.email = email

    @property
    def fullname(self):
        name = self.name or _("Anonymous")
        if self.email:
            return '%s <%s>' % (name, self.email)
        else:
            return name

    def has_logo(self):
        return False

    def url(self, controller='anonymous', action=None, **kwargs):
        if action is None:
            return 'mailto:%s' % self.email
        else:
            return url(controller=controller, action=action, **kwargs)


class Email(object):
    """Class representing one email address of a user."""

    def __init__(self, email):
        self.email = email.strip().lower()

    @classmethod
    def get(cls, email):
        try:
            return meta.Session.query(Email).filter(Email.email == email.lower()).one()
        except NoResultFound:
            return None


class ImplicitMedal(object):
    """Helper for medals.

    This is a separate class from Medal so that implicit medals can be
    instantiated without touching the database.
    """

    MEDAL_IMG_PATH = '/images/medals/'
    MEDAL_SIZE = dict(height=26, width=26)

    def __init__(self, user, medal_type):
        assert medal_type in self.available_medal_types(), medal_type
        self.user = user
        self.medal_type = medal_type

    @staticmethod
    def available_medals():
        return [
                ('admin2', _('Admin')),
                ('support2', _('Distinguished moderator')),
                ('ututiman2', _('Champion')),
                ('ututiman', _('Distinguished user')),
                ('buyer2', _('Gold sponsor')),
                ('buyer', _('Sponsor')),
                ('support', _('Moderator')),
                ('admin', _('Group admin')),
                ]

    @staticmethod
    def available_medal_types():
        return [m[0] for m in Medal.available_medals()]

    def url(self):
        return self.MEDAL_IMG_PATH + self.medal_type + '.png'

    def title(self):
        return dict(self.available_medals())[self.medal_type]

    def img_tag(self):
        return image(self.url(), alt=self.title(), title=self.title(),
                     **self.MEDAL_SIZE)


class Medal(ImplicitMedal):
    """A persistent medal for a user."""


class Teacher(User):
    """A separate class for the teachers at Ututi."""
    is_teacher = True

    def __init__(self, **kwargs):
        self.teacher_verified = False
        super(Teacher, self).__init__(**kwargs)

    def teaches(self, subject):
        return subject in self.taught_subjects

    def teach_subject(self, subject):
        if not self.teaches(subject):
            self.taught_subjects.append(subject)

    def unteach_subject(self, subject):
        if self.teaches(subject):
            self.taught_subjects.remove(subject)

    @property
    def share_info(self):
        if self.location:
            caption = ' '.join(self.location.title_path) + ' ' + _("teacher")
        else:
            caption = _("Teacher")
        return dict(title=self.fullname,
                    caption=caption,
                    link=self.url(qualified=True),
                    description=self.description)


class GroupNotFoundException(Exception):
    pass


class TeacherGroup(object):
    def __init__(self, title, email):
        self.title = title
        self.email = email
        self.update_binding()

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    def update_binding(self):
        from ututi.model import Group
        hostname = config.get('mailing_list_host', 'groups.ututi.lt')
        self.group = None
        if self.email.endswith(hostname):
            group = Group.get(self.email[:-(len(hostname)+1)])
            if group is not None:
                self.group = group
            else:
                raise GroupNotFoundException()


class UserRegistration(object):
    """Pending registration confirmations."""

    def __init__(self, email, location):
        self.email = email
        self.location = location
        self.hash = hashlib.md5(datetime.now().isoformat() + \
                                email).hexdigest()

    @classmethod
    def get(cls, hash):
        try:
            return meta.Session.query(cls).filter(cls.hash == hash).one()
        except NoResultFound:
            return None

    @classmethod
    def get_by_email(cls, email):
        try:
            return meta.Session.query(cls).filter(cls.email == email).one()
        except NoResultFound:
            return None

    def update_password(self, password_plain):
        self.password = generate_password(password_plain)

    def update_logo_from_facebook(self):
        """TODO: implement this."""
        pass

    def create_user(self):
        """Returns a User object filled with registration data."""
        user = User(fullname=self.fullname,
                    username=self.email,
                    location=self.location,
                    password=self.password,
                    gen_password=False)

        email = Email(self.email)
        email.confirmed = True
        user.emails.append(email)
        if self.openid_email:
            # add openid email as a second user's mail.
            email = Email(self.openid_email)
            email.confirmed = True
            user.emails.append(email)

        user.accepted_terms = datetime.utcnow()
        user.openid = self.openid
        user.facebook_id = self.facebook_id
        user.inviter = self.inviter
        return user

user_registrations_table = None
