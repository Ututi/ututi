"""The application's model objects"""
import sys
import os
import hashlib
import sha, binascii
import lxml
import logging
import warnings
import string
from random import Random
from binascii import a2b_base64, b2a_base64
from pylons import url
from random import randrange
import pkg_resources
from datetime import date, datetime
from ututi.lib import urlify

from pylons import config
from pylons.templating import render_mako_def

from sqlalchemy import orm, Column, Integer, Sequence, Table
from sqlalchemy.types import Unicode
from sqlalchemy.exc import DatabaseError, SAWarning
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import relation, backref, deferred
from sqlalchemy import func
from sqlalchemy.sql.expression import desc
from sqlalchemy.sql.expression import and_, or_

from ututi.migration import GreatMigrator
from ututi.model import meta
from ututi.lib.emails import group_invitation_email
from ututi.lib.security import check_crowds
from nous.mailpost import copy_chunked

from zope.cachedescriptors.property import Lazy

from pylons.i18n import _

log = logging.getLogger(__name__)

def init_model(engine):
    """Call me before using any of the tables or classes in the model"""
    ## Reflected tables must be defined and mapped here
    meta.Session.configure(bind=engine)
    meta.engine = engine


def setup_orm(engine):
    #relationships between content items and tags
    global files_table
    files_table = Table("files", meta.metadata,
                        Column('filename', Unicode(assert_unicode=True)),
                        Column('folder', Unicode(assert_unicode=True)),
                        Column('title', Unicode(assert_unicode=True)),
                        Column('description', Unicode(assert_unicode=True)),
                        autoload=True,
                        useexisting=True,
                        autoload_with=engine)

    global forum_posts_table
    forum_posts_table = Table("forum_posts", meta.metadata,
                              Column('title', Unicode(assert_unicode=True)),
                              Column('message', Unicode(assert_unicode=True)),
                              autoload=True,
                              useexisting=True,
                              autoload_with=engine)

    global users_table
    users_table = Table("users", meta.metadata,
                        Column('id', Integer, Sequence('users_id_seq'), primary_key=True),
                        Column('fullname', Unicode(assert_unicode=True)),
                        Column('description', Unicode(assert_unicode=True)),
                        Column('site_url', Unicode(assert_unicode=True)),
                        autoload=True,
                        useexisting=True,
                        autoload_with=engine)

    global content_items_table
    content_items_table = Table("content_items", meta.metadata,
                                autoload=True,
                                autoload_with=engine)

    global content_tags_table
    content_tags_table = Table("content_tags", meta.metadata,
                               autoload=True,
                               autoload_with=engine)

    global tags_table
    tags_table = Table("tags", meta.metadata,
                               Column('id', Integer, Sequence('tags_id_seq'), primary_key=True),
                               Column('title_short', Unicode(assert_unicode=True)),
                               Column('title', Unicode(assert_unicode=True)),
                               Column('description', Unicode(assert_unicode=True)),
                               Column('site_url', Unicode(assert_unicode=True)),
                               useexisting=True,
                               autoload=True,
                               autoload_with=engine)
    tag_mapper = orm.mapper(Tag,
                            tags_table,
                            polymorphic_on=tags_table.c.tag_type,
                            polymorphic_identity='',
                            properties={'logo': deferred(tags_table.c.logo)})

    orm.mapper(LocationTag,
               inherits=Tag,
               polymorphic_on=tags_table.c.tag_type,
               polymorphic_identity='location',
               properties = {'children': relation(LocationTag, order_by=LocationTag.title.asc(), backref=backref('parent', remote_side=tags_table.c.id))})

    orm.mapper(SimpleTag,
               inherits=tag_mapper,
               polymorphic_on=tags_table.c.tag_type,
               polymorphic_identity='tag')

    orm.mapper(ContentItem,
               content_items_table,
               polymorphic_on=content_items_table.c.content_type,
               polymorphic_identity='generic',
               properties = {'created': relation(User,
                                                 primaryjoin=content_items_table.c.created_by==users_table.c.id),
                             'modified': relation(User,
                                                  primaryjoin=content_items_table.c.modified_by==users_table.c.id),
                             'deleted': relation(User,
                                                 primaryjoin=content_items_table.c.deleted_by==users_table.c.id),
                             'tags': relation(SimpleTag,
                                              secondary=content_tags_table),
                             'location': relation(LocationTag)})

    orm.mapper(File, files_table,
               inherits=ContentItem,
               inherit_condition=files_table.c.id==ContentItem.id,
               polymorphic_identity='file',
               polymorphic_on=content_items_table.c.content_type,
               extension=NotifyGG(),
               properties = {'parent': relation(ContentItem,
                                                primaryjoin=files_table.c.parent_id==content_items_table.c.id,
                                                backref=backref("files", order_by=files_table.c.filename.asc()))})

    orm.mapper(ForumPost, forum_posts_table,
               inherits=ContentItem,
               inherit_condition=forum_posts_table.c.id==ContentItem.id,
               polymorphic_identity='forum_post',
               polymorphic_on=content_items_table.c.content_type,
               properties = {'parent': relation(ContentItem,
                                                primaryjoin=forum_posts_table.c.parent_id==content_items_table.c.id,
                                                backref="forum_posts")})

    orm.mapper(User,
               users_table,
               properties = {'emails': relation(Email, backref='user'),
                             'logo': deferred(users_table.c.logo)})

    global emails_table
    emails_table = Table("emails", meta.metadata,
                         autoload=True,
                         autoload_with=engine)
    orm.mapper(Email, emails_table)

    global subject_pages_table
    subject_pages_table = Table("subject_pages", meta.metadata,
                                autoload=True,
                                autoload_with=engine)

    global pages_table
    pages_table = Table("pages", meta.metadata,
                        autoload=True,
                        autoload_with=engine)
    orm.mapper(Page, pages_table,
               inherits=ContentItem,
               polymorphic_identity='page',
               polymorphic_on=content_items_table.c.content_type)

    global page_versions_table
    page_versions_table = Table("page_versions", meta.metadata,
                                Column('title', Unicode(assert_unicode=True)),
                                Column('content', Unicode(assert_unicode=True)),
                                autoload=True,
                                autoload_with=engine)
    orm.mapper(PageVersion, page_versions_table,
               inherits=ContentItem,
               polymorphic_identity='page_version',
               polymorphic_on=content_items_table.c.content_type,
               inherit_condition=page_versions_table.c.id == content_items_table.c.id,
               properties={'page': relation(Page,
                                            primaryjoin=pages_table.c.id==page_versions_table.c.page_id,
                                            backref=backref('versions',
                                                            order_by=content_items_table.c.created_on.desc()))})

    global subjects_table
    subjects_table = Table("subjects", meta.metadata,
                           Column('title', Unicode(assert_unicode=True)),
                           Column('lecturer', Unicode(assert_unicode=True)),
                           Column('description', Unicode(assert_unicode=True)),
                           autoload=True,
                           useexisting=True,
                           autoload_with=engine)
    orm.mapper(Subject, subjects_table,
               inherits=ContentItem,
               polymorphic_identity='subject',
               polymorphic_on=content_items_table.c.content_type,
               properties={'pages': relation(Page,
                                             secondary=subject_pages_table,
                                             backref="subject")})

    global group_membership_types_table
    group_membership_types_table = Table("group_membership_types", meta.metadata,
                                         autoload=True,
                                         autoload_with=engine)
    orm.mapper(GroupMembershipType,
               group_membership_types_table)

    global group_members_table
    group_members_table = Table("group_members", meta.metadata,
                                autoload=True,
                                autoload_with=engine)
    orm.mapper(GroupMember,
               group_members_table,
               properties = {'user': relation(User, backref='memberships'),
                             'group': relation(Group, backref=backref('members', cascade='save-update, merge, delete')),
                             'role': relation(GroupMembershipType)})


    global groups_table
    groups_table = Table("groups", meta.metadata,
                         Column('title', Unicode(assert_unicode=True)),
                         Column('description', Unicode(assert_unicode=True)),
                         Column('page', Unicode(assert_unicode=True)),
                         useexisting=True,
                         autoload=True,
                         autoload_with=engine)

    global group_watched_subjects_table
    group_watched_subjects_table = Table("group_watched_subjects", meta.metadata,
                                         autoload=True,
                                         autoload_with=engine)

    orm.mapper(Group, groups_table,
               inherits=ContentItem,
               polymorphic_identity='group',
               polymorphic_on=content_items_table.c.content_type,
               properties ={'watched_subjects': relation(Subject,
                                                         secondary=group_watched_subjects_table),
                            'logo': deferred(groups_table.c.logo)})

    global group_invitations_table
    group_invitations_table = Table("group_invitations", meta.metadata,
                                    autoload=True,
                                    autoload_with=engine)

    global group_requests_table
    group_requests_table = Table("group_requests", meta.metadata,
                                    autoload=True,
                                    autoload_with=engine)

    orm.mapper(PendingRequest, group_requests_table,
               properties = {'group': relation(Group, backref=backref('requests', cascade='save-update, merge, delete')),
                             'user': relation(User,
                                              primaryjoin=group_requests_table.c.user_id==users_table.c.id,
                                              backref='requests')})

    orm.mapper(PendingInvitation, group_invitations_table,
               properties = {'user': relation(User,
                                              primaryjoin=group_invitations_table.c.user_id==users_table.c.id,
                                              backref='invitations'),
                             'author': relation(User,
                                                primaryjoin=group_invitations_table.c.author_id==users_table.c.id),
                             'group': relation(Group, backref=backref('invitations', cascade='save-update, merge, delete'))})

    global user_monitored_subjects_table
    user_monitored_subjects_table = Table("user_monitored_subjects", meta.metadata,
                                        autoload=True,
                                        autoload_with=engine)

    orm.mapper(UserSubjectMonitoring, user_monitored_subjects_table,
               properties ={'subject': relation(Subject),
                            'user': relation(User)
                            })

    # ignoring error about unknown column type for now
    warnings.simplefilter("ignore", SAWarning)

    global search_items_table
    search_items_table = Table("search_items", meta.metadata,
                               autoload=True,
                               autoload_with=engine)

    warnings.simplefilter("default", SAWarning)

    orm.mapper(SearchItem, search_items_table,
               properties={'object' : relation(ContentItem)})

    global blog_table
    blog_table = Table("blog", meta.metadata,
                       Column('content', Unicode(assert_unicode=True)),
                       autoload=True,
                       useexisting=True,
                       autoload_with=engine)

    orm.mapper(BlogEntry, blog_table)

    from ututi.model import mailing
    mailing.setup_orm(engine)

    from ututi.model import events
    events.setup_orm(engine)


def reset_db(engine):
    connection = meta.engine.connect()
    connection.execute("drop schema public cascade;")
    connection.execute("create schema public;")
    connection.close()


def initialize_dictionaries(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "model/stemming.sql").split(";;")
    connection = meta.engine.connect()
    for statement in initial_db_data:
        statement = statement.strip()
        if (statement):
            try:
                txn = connection.begin()
                connection.execute(statement)
                txn.commit()
            except DatabaseError, e:
                print >> sys.stderr, ""
                print >> sys.stderr, e.message
                print >> sys.stderr, e.statement
                txn.rollback()
                return
    connection.close()


def initialize_db_defaults(engine):
    initial_db_data = pkg_resources.resource_string(
        "ututi",
        "model/defaults.sql").split(";;")
    connection = meta.engine.connect()
    for statement in initial_db_data:
        statement = statement.strip()
        if (statement):
            try:
                txn = connection.begin()
                connection.execute(statement)
                txn.commit()
            except DatabaseError, e:
                print >> sys.stderr, ""
                print >> sys.stderr, e.message
                print >> sys.stderr, e.statement
                txn.rollback()
                return
    connection.close()
    migrator = GreatMigrator(engine)
    migrator.initializeVersionning()


def teardown_db_defaults(engine, quiet=False):
    connection = meta.engine.connect()
    tx = connection.begin()
    connection.execute("drop schema public cascade")
    connection.execute("create schema public")
    tx.commit()
    connection.close()


content_items_table = None
class ContentItem(object):
    """A generic class for content items."""

    def url(self):
        raise NotImplementedError("This method should be overridden by content"
                                  " objects to provide their urls.")

    def snippet(self):
        """Render a short snippet with the basic item's information. Used in search to render the results."""
        return render_mako_def('/sections/content_snippets.mako','generic', object=self)


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
    return b2a_base64(sha.new(password + salt).digest() + salt)[:-1]


def validate_password(reference, password):
    """Verify a password given the original hash."""
    try:
        ref = a2b_base64(reference)
    except binascii.Error:
        return False
    salt = ref[20:]
    compare = b2a_base64(sha.new(password + salt).digest() + salt)[:-1]
    return compare == reference


class UserSubjectMonitoring(object):

    def __init__(self, user, subject, ignored=False):
        self.user, self.subject, self.ignored = user, subject, ignored


users_table = None
user_monitored_subjects_table = None

class User(object):

    def send(self, msg):
        """Send a message to the user."""
        email = self.emails[0]
        if email.confirmed or msg.force:
            msg.send(email.email)
        else:
            log.info("Could not send message to uncofirmed email %(email)s" % dict(email=email.email))

    def checkPassword(self, password):
        """Check the user's password."""
        return validate_password(self.password, password)

    @classmethod
    def authenticate(cls, username, password):
        try:
            user = meta.Session.query(Email).filter_by(email=username.strip().lower()).one().user
            if validate_password(user.password, password):
                return username
            else:
                return None
        except NoResultFound:
            return None
        return None

    @classmethod
    def get(cls, username):
        """Get a user by his email."""
        try:
            return meta.Session.query(Email).filter_by(email=username.lower()).one().user
        except NoResultFound:
            return None

    @classmethod
    def get_byid(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    @property
    def ignored_subjects(self):
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

    def url(self, controller='user', action='index'):
        return url(controller=controller,
                   action=action,
                   id=self.id)

    def watches(self, subject):
        return subject in self.watched_subjects

    @property
    def groups(self):
        return [membership.group
                for membership in self.memberships]

    def __init__(self, fullname, password, gen_password=True):
        self.fullname = fullname
        self.update_password(password, gen_password)

    def update_password(self, password, gen_password=True):
        self.password = password
        if gen_password:
            self.password = generate_password(password)

    @property
    def isConfirmed(self):
        return self.emails[0].confirmed

email_table = None

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


class Folder(list):

    def __init__(self, title, parent):
        self.title = title
        self.parent = parent

    def can_write(self, user=None):
        if len(self) == 0 and user is None:
            return False
        can_write = True
        for file in self:
            can_write = can_write and file.can_write(user)
        return can_write


class FolderMixin(object):

    @property
    def folders_dict(self):
        result = {'': Folder('', parent=self)}
        for file in self.files:
            result.setdefault(file.folder, Folder(file.folder, parent=self))
            if not file.isNullFile():
                result[file.folder].append(file)
        return result

    @property
    def file_count(self):
        return len([file for file in self.files if not file.isNullFile()])

    def getFolder(self, title):
        return self.folders_dict.get(title, None)

    @property
    def folders(self):
        return sorted(self.folders_dict.values(), key=lambda f: f.title)


group_watched_subjects_table = None
groups_table = None

class Group(ContentItem, FolderMixin):

    def send(self, msg):
        msg.send([mship.user for mship in self.members])

    def recipients(self, period):
        recipients = meta.Session.query(GroupMember).\
            filter_by(group=self, receive_email_each=period).all()
        return [recipient.user for recipient in recipients]

    def recipients_gg(self):
        recipients = meta.Session.query(GroupMember).\
            filter_by(group=self).all()
        return [recipient.user for recipient in recipients
                if recipient.user.gadugadu_get_news == True]

    @classmethod
    def get(cls, id):
        query = meta.Session.query(cls)
        try:
            if isinstance (id, (long, int)):
                return query.filter_by(id=id).one()
            else:
                return query.filter(func.lower(cls.group_id)==id.strip().lower()).one()
        except NoResultFound:
            return None

    @property
    def list_address(self):
        return "%s@%s" % (self.group_id, config.get('mailing_list_host', ''))

    @property
    def last_seen_members(self):
        gmt = group_members_table
        return meta.Session.query(User).join((gmt,
                                      gmt.c.user_id == users_table.c.id))\
                                      .filter(gmt.c.group_id == self.id)\
                                      .order_by(User.last_seen.desc()).all()

    def is_subscribed(self, user):
        membership = GroupMember.get(user, self)
        return membership and membership.subscribed

    def is_member(self, user):
        """Is the user a member of the group?"""
        return GroupMember.get(user, self)

    def is_admin(self, user):
        """Is the user an administrator of the group?"""
        membership = GroupMember.get(user, self)
        return membership and membership.is_admin

    @property
    def administrators(self):
        """List of all the administrators of the group."""
        admin_type = GroupMembershipType.get('administrator')
        return [membership.user for membership in self.members if membership.role == admin_type]

    def add_member(self, user, admin=False):
        if not self.is_member(user):
            membership = GroupMember(user, self, admin)
            meta.Session.add(membership)

    def url(self, controller='group', action='index', **kwargs):
        return url(controller=controller, action=action, id=self.group_id, **kwargs)

    def invite_user(self, email, author):
        user = User.get(email)
        if user is None or not self.is_member(user):
            try:
                invitation = meta.Session.query(PendingInvitation).filter_by(email=email, group=self).one()
                invitation.created = datetime.today()
            except NoResultFound:
                invitation = PendingInvitation(email, author=author, group=self)
                meta.Session.add(invitation)
            group_invitation_email(invitation, email)
            return invitation
        else:
            return None

    def request_join(self, user):
        request = PendingRequest(user, group=self)
        meta.Session.add(request)
        return request

    def snippet(self):
        """Render the group's information."""
        return render_mako_def('/sections/content_snippets.mako','group', object=self)


    def __init__(self, group_id, title=u'', location=None, year=None, description=u''):
        self.group_id = group_id.strip().lower()
        self.title = title
        self.location = location
        self.page = u''
        if year is None:
            year = date(date.today().year, 1, 1)
        self.year = year
        self.description = description

    @property
    def all_messages(self):
        return meta.Session.query(GroupMailingListMessage)\
            .filter_by(group_id=self.id)\
            .order_by(GroupMailingListMessage.sent.desc())\
            .all()

    def all_files(self, limit=None):
        ids = [subject.id for subject in self.watched_subjects]
        ids.append(self.id)

        files = meta.Session.query(File).filter(File.parent_id.in_(ids)).filter(File.md5 != None).order_by(File.created_on.desc())
        if limit is not None:
            files = files.limit(limit)
        return files.all()

    @property
    def group_events(self):
        from ututi.model.events import Event
        events = meta.Session.query(Event)\
            .filter(or_(Event.object_id.in_([s.id for s in self.watched_subjects]),
                        Event.object_id == self.id))\
                        .order_by(Event.created.desc())\
                        .limit(20).all()
        return events

    @property
    def message_count(self):
        from ututi.model.mailing import GroupMailingListMessage
        return meta.Session.query(GroupMailingListMessage)\
            .filter_by(group_id=self.id, reply_to=None)\
            .order_by(desc(GroupMailingListMessage.sent))\
            .count()


group_members_table = None

class GroupMember(object):
    """A membership object that associates a user with a group.

    It has attributes for `group', `user' and `membership_type',
    membership types are listed in group_membership_types table.
    """
    def __init__(self, user=None, group=None, admin=False):
        """Create a group membership object."""
        role_admin = GroupMembershipType.get('administrator')
        role_member = GroupMembershipType.get('member')
        self.user = user
        self.group = group
        self.role = role_member
        if admin:
            self.role = role_admin

    @classmethod
    def get(cls, user, group):
        try:
            return meta.Session.query(cls).filter(GroupMember.user == user).filter(GroupMember.group == group).one()
        except NoResultFound:
            return None

    @property
    def is_admin(self):
        return self.role == GroupMembershipType.get('administrator')


class GroupMembershipType(object):

    @classmethod
    def get(cls, membership_type):
        try:
            return meta.Session.query(cls).filter_by(membership_type=membership_type).one()
        except NoResultFound:
            return None


group_requests_table = None

class PendingInvitation(object):
    """The group invites a user."""
    def __init__(self, email, group = None, author=None):
        self.author = author
        self.hash = ''.join(Random().sample(string.ascii_lowercase, 8))
        if group is not None:
            self.group = group

        user = User.get(email)
        if user is not None:
            self.user = user

        self.email = email

    @classmethod
    def get(cls, hash):
        try:
            return meta.Session.query(cls).filter(cls.hash == hash).one()
        except NoResultFound:
            return None


group_invitations_table = None

class PendingRequest(object):
    """The user requests to join a group."""
    def __init__(self, user, group = None):
        self.hash = ''.join(Random().sample(string.ascii_lowercase, 8))
        if group is not None:
            self.group = group

        if user is not None:
            self.user = user

    @classmethod
    def get(cls, user, group):
        """Return a a group request matching the user and the group."""
        try:
            return meta.Session.query(PendingRequest).filter(and_(PendingRequest.user == user, PendingRequest.group == group)).one()
        except NoResultFound:
            return None


subjects_table = None
class Subject(ContentItem, FolderMixin):

    def recipients(self, period):
        all_recipients = []
        groups =  meta.Session.query(Group).filter(Group.watched_subjects.contains(self)).all()
        for group in groups:
            all_recipients.extend(group.recipients(period))

        usms = meta.Session.query(UserSubjectMonitoring).\
            filter(UserSubjectMonitoring.subject==self).\
            filter(User.receive_email_each==period).all()
        recipients = [usm.user for usm in usms]
        all_recipients.extend(recipients)
        return list(set(all_recipients))

    def recipients_gg(self):
        all_recipients = []
        groups =  meta.Session.query(Group).filter(Group.watched_subjects.contains(self)).all()
        for group in groups:
            all_recipients.extend(group.recipients_gg())

        usms = meta.Session.query(UserSubjectMonitoring).\
            filter(UserSubjectMonitoring.subject==self).\
            filter(User.gadugadu_get_news==True).all()
        recipients = [usm.user for usm in usms]
        all_recipients.extend(recipients)
        return list(set(all_recipients))

    @classmethod
    def get(cls, location, id):
        try:
            return meta.Session.query(cls).filter_by(subject_id=id, location=location).one()
        except NoResultFound:
            return None

    @classmethod
    def get_by_id(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=id).one()
        except NoResultFound:
            return None

    @property
    def location_path(self):
        location = self.location
        path = []
        while location:
            path.append(location.title_short)
            location = location.parent
        return '/'.join(reversed(path))

    def url(self, controller='subject', action='home', **kwargs):
        return url(controller=controller,
                   action=action,
                   id=self.subject_id,
                   tags=self.location_path,
                   **kwargs)

    def snippet(self):
        """Render a short snippet with the basic item's information. Used in search to render the results."""
        return render_mako_def('/sections/content_snippets.mako','subject', object=self)

    def generate_new_id(self):
        title = urlify(self.title, 20)
        lecturer = urlify(self.lecturer or '', 10)

        alternative_ids = [
            '%(title)s' % dict(title=title),
            '%(title)s-%(lecturer)s' % dict(title=title, lecturer=lecturer),
            '%(title)s-%(id)i' % dict(title=title, id=self.id),
            '%(title)s-%(lecturer)s-%(id)i' % dict(title=title, lecturer=lecturer, id=self.id)]
        if self.lecturer is None or self.lecturer.strip() == u'':
            del(alternative_ids[3])
            del(alternative_ids[1])

        for sid in alternative_ids:
            exist = Subject.get(self.location, sid)
            if exist is None:
                return sid
        return None

    def __init__(self, subject_id, title, location, lecturer=None, description=None, tags=[]):
        self.location = location
        self.title = title
        self.subject_id = subject_id
        self.lecturer = lecturer
        self.description = description
        self.tags = tags


pages_table = None

class Page(ContentItem):
    """Class representing user-editable wiki-like pages."""

    @classmethod
    def get(cls, id):
        try:
            return meta.Session.query(cls).filter_by(id=int(id)).one()
        except NoResultFound:
            return None

    def __init__(self, title, content):
        """The first version of a page is created automatically."""
        self.add_version(title, content)

    def add_version(self, title, content):
        version = PageVersion(title, content)
        self.versions.append(version)

    def save(self, title, content):
        if title != self.title or content != self.content:
            version = PageVersion(title, content)
            self.versions.append(version)

    @property
    def last_version(self):
        if self.versions:
            return self.versions[0]
        else:
            raise AttributeError("This page has no versions!")

    @property
    def title(self):
        return self.last_version.title

    @property
    def content(self):
        return self.last_version.content

    @property
    def author(self):
        return self.last_version.author

    @property
    def created(self):
        return self.last_version.created

    def url(self, **kwargs):
        return url(controller='subjectpage',
                   action='index',
                   page_id=self.id,
                   id=self.subject[0].subject_id,
                   tags=self.subject[0].location_path,
                   **kwargs)

    def snippet(self):
        """Render a short snippet with the basic item's information. Used in search to render the results."""
        return render_mako_def('/sections/content_snippets.mako','page', object=self)


page_versions_table = None

class PageVersion(ContentItem):
    """Class representing one version of a page."""

    def __init__(self, title, content):
        self.title = title
        self.content = content

    @property
    def plain_text(self):
        doc = lxml.html.fragment_fromstring(self.content, create_parent=True)
        texts = doc.xpath('//text()')
        return ' '.join(texts)


content_tags_table = None
class Tag(object):
    """Class representing tags in general."""

    def __init__(self, title, title_short, description):
        self.title = title
        self.description = description

    @classmethod
    def get(cls, id):
        tag = meta.Session.query(cls)
        if isinstance(id, basestring):
            tag.filter_by(title=id.lower())
        else:
            tag.filter_by(id=id)
        try:
            return tag.one()
        except NoResultFound:
            return None

class SimpleTag(Tag):
    """Class for simple (i.e. not location or hierarchy -aware) tags."""

    def __init__(self, title):
        self.title = title.lower()

    def hierarchy(self, full=False):
        if full:
            return [self]
        else:
            return [self.title]

    @classmethod
    def get(cls, title, create=True):
        """The method queries for a matching tag, if not found, creates one."""
        try:
            tag = meta.Session.query(cls).filter_by(title=title.lower()).one()
        except NoResultFound:
            if create:
                tag = cls(title)
                meta.Session.add(tag)
            else:
                tag = None

        return tag


class LocationTag(Tag):
    """Class representing the university and faculty tags."""

    def __init__(self, title, title_short, description, parent=None, confirmed=True):
        self.parent = parent
        self.title = title
        self.title_short = title_short
        self.description = description
        self.confirmed = confirmed

    @property
    def path(self):
        location = self
        path = []
        while location:
            path.append(location.title_short.lower())
            location = location.parent
        return list(reversed(path))

    def hierarchy(self, full=False):
        """Return a list of titles (or the full tags) of all the parents of the tag, including the tag itself."""
        location = self
        path = []
        while location:
            if full:
                path.append(location)
            else:
                path.append(location.title)
            location = location.parent
        return list(reversed(path))

    @Lazy
    def flatten(self):
        """Return a list of the tag's children and the tag's children's children, etc."""
        flat = [self]
        for child in self.children:
            flat.extend(child.flatten)
        return flat

    @classmethod
    def get(cls, path):

        if isinstance(path, basestring):
            path = path.split('/')

        tag = None
        for title_short in filter(bool, path):
            try:
                tag = meta.Session.query(cls)\
                    .filter(func.lower(LocationTag.title_short)==title_short.lower()).filter_by(parent=tag).one()
            except NoResultFound:
                return None
        return tag

    @classmethod
    def get_by_title(cls, title):
        """A method to return the tag either by its full title or its short title.

        A list can be passed for hierarchical traversal.
        """
        hierarchy = True
        if not isinstance(title, list):
            title = [title]
            hierarchy = False

        tag = None
        for title_full in filter(bool, title):
            try:
                q = meta.Session.query(cls).filter(func.lower(LocationTag.title)==title_full.lower())
                if hierarchy:
                    q = q.filter_by(parent=tag)
                tag =  q.one()
            except NoResultFound:
                try:
                    q = meta.Session.query(cls).filter(func.lower(LocationTag.title_short)==title_full.lower())
                    if hierarchy:
                        q = q.filter_by(parent=tag)
                    tag =  q.one()
                except NoResultFound:
                    tag = None
                    break
        return tag

    @classmethod
    def get_all(cls, title):
        items = meta.Session.query(cls).filter(or_(func.lower(LocationTag.title)==title.lower(), func.lower(LocationTag.title_short)==title.lower())).all()
        #items.extend(meta.Session.query(cls).filter_by(title_short=title).all())
        return items

    def url(self, controller='structureview', action='index', **kwargs):
        return url(controller=controller,
                   action=action,
                   path='/'.join(self.path),
                   **kwargs)

    def count(self, obj=Subject):
        if isinstance(obj, basestring):
            obj_types = {
                'subject' : Subject,
                'group' : Group,
                'file' : File,
                }
            obj = obj_types[obj.lower()]
        ids = [t.id for t in self.flatten]
        return meta.Session.query(obj).filter(obj.location_id.in_(ids)).count()

    @Lazy
    def stats(self):
        ids = [t.id for t in self.flatten]
        counts = meta.Session.query(ContentItem.content_type, func.count(ContentItem.id))\
            .filter(ContentItem.location_id.in_(ids)).group_by(ContentItem.content_type).all()
        res = {'subject': 0, 'group': 0, 'file': 0}
        res.update(dict(counts))
        return res

    @Lazy
    def rating(self):
        """Calculate the rating of a university."""
        stats = self.stats
        return (stats["subject"] + 1) * (stats["file"] + 1) * (stats["group"] + 1)

    def latest_groups(self):
        ids = [t.id for t in self.flatten]
        grps =  meta.Session.query(Group).filter(Group.location_id.in_(ids)).order_by(Group.created_on.desc()).limit(5).all()
        return grps


def cleanupFileName(filename):
    return filename.split('\\')[-1].split('/')[-1]


from sqlalchemy.orm.interfaces import MapperExtension
class NotifyGG(MapperExtension):

    def after_insert(self, mapper, connection, instance):
        if instance.isNullFile():
            return
        from pylons import tmpl_context as c
        from ututi.lib import gg
        recipients = []
        if isinstance(instance.parent, (Group, Subject)):
            for interested_user in instance.parent.recipients_gg():
                if interested_user is not c.user:
                    recipients.append(interested_user.gadugadu_uin)

        for uin in sorted(recipients):
            msg = _("A new file has been uploaded for the %(title)s:")
            gg.send_message(uin, msg % {
                    'title': instance.parent.title})
            msg = "%s (%s)" % (instance.title, instance.url(qualified=True))
            gg.send_message(uin, msg)


class File(ContentItem):
    """Class representing user-uploaded files."""

    def can_write(self, user=None):
        can_write = False
        if isinstance(self.parent, Subject):
            can_write = check_crowds(['moderator'], context=self.parent, user=user)
        return can_write or check_crowds(['owner'], context=self, user=user)

    def copy(self):
        """Copy the file."""
        new_file = File(self.filename, self.title,
                        mimetype=self.mimetype,
                        description=self.description,
                        md5=self.md5,
                        folder=self.folder)
        from ututi.lib.security import current_user
        new_file.created = current_user()
        return new_file

    def __init__(self, filename, title, mimetype=None, created=None,
                 description=u'', data=None, md5=None, folder=u''):
        if data is not None:
            md5_digest = hashlib.md5(data).hexdigest()
            if md5 is not None:
                assert md5 == md5_digest
            self.md5 = md5_digest
            self.filesize = len(data)

        if md5 is not None:
            self.md5 = md5

        self.filename = cleanupFileName(filename)
        self.title = cleanupFileName(title)
        if mimetype is not None:
            self.mimetype = mimetype
        if created is not None:
            self.created = created
            self.modified = created
        self.description = description
        self.folder = folder

    @classmethod
    def makeNullFile(cls, folder):
        result = cls(u"Null File", u"Null File", folder=folder)
        return result

    def isNullFile(self):
        return self.md5 == None

    def filepath(self):
        """Calculate the path of a file, based on its md5 checksum."""
        dir_path = [config.get('files_path')]
        segment = ''
        for c in list(self.md5):
            segment += c
            if len(segment) > 7:
                dir_path.append(segment)
                segment = ''
        if segment:
            dir_path.append(segment)

        return os.path.join(*dir_path)

    def store(self, data):
        """Store a given file in the database and the filesystem."""
        self.md5 = self.hash_chunked(data)
        filename = self.filepath()
        if os.path.exists(filename):
            return

        if not os.path.exists(os.path.dirname(filename)):
            os.makedirs(os.path.dirname(filename))
        f = open(filename, 'w')
        size = copy_chunked(data, f, 4096)
        self.filesize = size

        f.close()

    def url(self, controller='files', action='get', **kwargs):
        from ututi.model.mailing import GroupMailingListMessage

        if isinstance(self.parent, Subject):
            return self.parent.url(controller='subjectfile',
                                   action=action,
                                   file_id=self.id,
                                   **kwargs)
        elif isinstance(self.parent, Group):
            return self.parent.url(controller='groupfile',
                                   action=action,
                                   file_id=self.id,
                                   **kwargs)
        elif isinstance(self.parent, GroupMailingListMessage):
            message = self.parent
            return message.group.url(controller='groupforum',
                                     action='file',
                                     message_id=message.id,
                                     file_id=self.id,
                                     **kwargs)
        raise AttributeError("Can't generate url for the file without a parent!")

    def hash_chunked(self, file):
        """Calculate the checksum of a file in chunks."""
        chunk_size = 8 * 1024**2
        size = 0
        hash = hashlib.md5()

        while True:
            if isinstance(file, basestring):
                chunk = file[size:(size+chunk_size)]
            else:
                chunk = file.read(chunk_size)

            size += len(chunk)
            hash.update(chunk)
            if len(chunk) < chunk_size:
                break

        if not isinstance(file, basestring):
            file.seek(0)

        return hash.hexdigest()

    @property
    def size(self):
        if self.filesize is not None:
            return self.filesize
        else:
            try:
                return os.path.getsize(self.filepath())
            except:
                return 0

    @classmethod
    def get(self, file_id):
        try:
            return meta.Session.query(File).filter_by(id=file_id).one()
        except NoResultFound:
            return None


class ForumPost(ContentItem):
    """ """

    def __init__(self, title, message, forum_id=None, thread_id=None):
        self.title = title
        self.message = message
        self.forum_id = forum_id
        self.thread_id = thread_id

    def url(self):
        return url(controller='forum', action='thread',
                   forum_id=self.forum_id, thread_id=self.thread_id)

blog_table = None
class BlogEntry(object):
    pass


search_items_table = None
class SearchItem(object):
    pass


# Reimports for convenience
from ututi.model.mailing import GroupMailingListMessage

# Events:
#
#   page added/modified
#   file added
#   message added
#   subject added/modified
#   member joined, invited, left, invitation accepted

# slicing
# user -> groups (pages, files, members?, messages) + subjects (pages, files)
# group -> subjects (pages, files) + group + pages + files + members

#   conversation, comment (feedback)
