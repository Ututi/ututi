"""The application's model objects"""
import sys
import os
import hashlib
import sha, binascii
import lxml
import warnings
import string
from random import Random
from binascii import a2b_base64, b2a_base64
from pylons import url
from random import randrange
import pkg_resources
from datetime import date, datetime

from pylons import config
from pylons.templating import render_mako_def

from sqlalchemy import orm, Column, Integer, Sequence, Table
from sqlalchemy.types import Unicode
from sqlalchemy.exc import DatabaseError, SAWarning
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.orm import relation, backref
from sqlalchemy import func
from sqlalchemy.sql.expression import and_, or_

from ututi.migration import GreatMigrator
from ututi.model import meta
from ututi.lib.emails import group_invitation_email
from ututi.lib.security import check_crowds
from nous.mailpost import copy_chunked


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

    global users_table
    users_table = Table("users", meta.metadata,
                        Column('id', Integer, Sequence('users_id_seq'), primary_key=True),
                        Column('fullname', Unicode(assert_unicode=True)),
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
                               useexisting=True,
                               autoload=True,
                               autoload_with=engine)
    tag_mapper = orm.mapper(Tag,
                            tags_table,
                            polymorphic_on=tags_table.c.tag_type,
                            polymorphic_identity='')

    orm.mapper(LocationTag,
               inherits=Tag,
               polymorphic_on=tags_table.c.tag_type,
               polymorphic_identity='location',
               properties = {'children': relation(LocationTag, backref=backref('parent', remote_side=tags_table.c.id))})

    orm.mapper(SimpleTag,
               inherits=tag_mapper,
               polymorphic_on=tags_table.c.tag_type,
               polymorphic_identity='tag')

    orm.mapper(ContentItem,
               content_items_table,
               polymorphic_on=content_items_table.c.content_type,
               polymorphic_identity='generic',
               properties = {'parent': relation(ContentItem, backref='children'),
                             'created': relation(User,
                                                 primaryjoin=content_items_table.c.created_by==users_table.c.id),
                             'modified': relation(User,
                                                  primaryjoin=content_items_table.c.modified_by==users_table.c.id),
                             'tags': relation(SimpleTag,
                                              secondary=content_tags_table),
                             'location': relation(LocationTag)})

    orm.mapper(File, files_table,
               inherits=ContentItem,
               polymorphic_identity='file',
               polymorphic_on=content_items_table.c.content_type)

    orm.mapper(User,
               users_table,
               properties = {'emails': relation(Email, backref='user')})

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

    global subject_files_table
    subject_files_table = Table("subject_files", meta.metadata,
                                autoload=True,
                                autoload_with=engine)
    global subjects_table
    subjects_table = Table("subjects", meta.metadata,
                           Column('title', Unicode(assert_unicode=True)),
                           Column('lecturer', Unicode(assert_unicode=True)),
                           autoload=True,
                           useexisting=True,
                           autoload_with=engine)
    orm.mapper(Subject, subjects_table,
               inherits=ContentItem,
               polymorphic_identity='subject',
               polymorphic_on=content_items_table.c.content_type,
               properties={'files': relation(File,
                                             secondary=subject_files_table),
                           'pages': relation(Page,
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
                             'group': relation(Group, backref=backref('members')),
                             'role': relation(GroupMembershipType)})


    global group_files_table
    group_files_table = Table("group_files", meta.metadata,
                              autoload=True,
                              autoload_with=engine)

    global groups_table
    groups_table = Table("groups", meta.metadata,
                         Column('title', Unicode(assert_unicode=True)),
                         Column('description', Unicode(assert_unicode=True)),
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
               properties ={'files': relation(File,
                                              secondary=group_files_table),
                            'watched_subjects': relation(Subject,
                                                         secondary=group_watched_subjects_table)})

    global group_invitations_table
    group_invitations_table = Table("group_invitations", meta.metadata,
                                    autoload=True,
                                    autoload_with=engine)

    global group_requests_table
    group_requests_table = Table("group_requests", meta.metadata,
                                    autoload=True,
                                    autoload_with=engine)

    orm.mapper(PendingRequest, group_requests_table,
               properties = {'group': relation(Group, backref='requests'),
                             'user': relation(User,
                                              primaryjoin=group_requests_table.c.user_id==users_table.c.id,
                                              backref='requests')})

    orm.mapper(PendingInvitation, group_invitations_table,
               properties = {'user': relation(User,
                                              primaryjoin=group_invitations_table.c.user_id==users_table.c.id,
                                              backref='invitations'),
                             'author': relation(User,
                                                primaryjoin=group_invitations_table.c.author_id==users_table.c.id),
                             'group': relation(Group, backref='invitations')})

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

    from ututi.model import mailing
    mailing.setup_orm(engine)

    from ututi.model import events
    events.setup_orm(engine)


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
                print >> sys.stderr, str(e)
                txn.rollback()
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
    password = str(password)
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
    def watched_subjects(self):
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
        group_watched_subjects = meta.Session.query(Subject)\
            .join((gwst,
                   and_(gwst.c.subject_id==subjects_table.c.id,
                        gwst.c.subject_id==subjects_table.c.id)))\
            .join((gmt, gmt.c.group_id == gwst.c.group_id))\
            .filter(gmt.c.user_id == self.id)
        return directly_watched_subjects.union(group_watched_subjects)\
            .except_(user_ignored_subjects).all()

    def _setWatchedSubject(self, subject, ignored):
        usm = meta.Session.query(UserSubjectMonitoring)\
            .filter_by(user=self, subject=subject).first()
        if usm is None:
            usm = UserSubjectMonitoring(self, subject, ignored=ignored)
            meta.Session.add(usm)
        else:
            usm.ignored = ignored

    def watchSubject(self, subject):
        self._setWatchedSubject(subject, ignored=False)

    def ignoreSubject(self, subject):
        self._setWatchedSubject(subject, ignored=True)

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

    def __init__(self, title):
        self.title = title

    def can_write(self, user=None):
        can_write = True
        for file in self:
            can_write = can_write and file.can_write(user)
        return can_write


class FolderMixin(object):

    @property
    def folders_dict(self):
        result = {'': Folder('')}
        for file in self.files:
            result.setdefault(file.folder, Folder(file.folder))
            if not file.isNullFile():
                result[file.folder].append(file)
        return result

    def getFolder(self, title):
        return self.folders_dict.get(title, None)

    @property
    def folders(self):
        return sorted(self.folders_dict.values(), key=lambda f: f.title)


group_watched_subjects_table = None
groups_table = None

class Group(ContentItem, FolderMixin):

    @classmethod
    def get(cls, id):
        query = meta.Session.query(cls)
        try:
            if isinstance (id, (long, int)):
                return query.filter_by(id=id).one()
            else:
                return query.filter_by(group_id=id).one()
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
                                .filter(gmt.c.group_id == self.id).all()

    def is_member(self, user):
        """Is the user a member of the group?"""
        members = [membership.user for membership in self.members]
        return user in members

    def is_admin(self, user):
        """Is the user an administrator of the group?"""
        admin_type = GroupMembershipType.get('administrator')
        admins = [membership.user for membership in self.members if membership.role == admin_type]
        return user in admins

    @property
    def administrators(self):
        """List of all the administrators of the group."""
        admin_type = GroupMembershipType.get('administrator')
        return [membership.user for membership in self.members if membership.role == admin_type]

    def add_member(self, user, admin=False):
        if not self.is_member(user):
            membership = GroupMember(user, self, admin)
            meta.Session.add(membership)

    def url(self, controller='group', action='home', **kwargs):
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
subject_files_table = None
class Subject(ContentItem, FolderMixin):

    def can_write(self, user=None):
        return check_crowds(['owner'], context=self, user=user)

    @classmethod
    def get(cls, location, id):
        try:
            return meta.Session.query(cls).filter_by(subject_id=id, location=location).one()
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

    def __init__(self, subject_id, title, location, lecturer=None):
        self.location = location
        self.title = title
        self.subject_id = subject_id
        self.lecturer = lecturer


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

    def url(self):
        return url(controller='subjectpage', action='index', page_id=self.id, id=self.subject[0].subject_id, tags=self.subject[0].location_path)

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
        if isinstance(id, unicode):
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

    def __init__(self, title, title_short, description, parent=None):
        self.parent = parent
        self.title = title
        self.title_short = title_short
        self.description = description

    @property
    def path(self):
        location = self
        path = []
        while location:
            path.append(location.title_short)
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

    def flatten(self):
        """Return a list of the tag's children and the tag's children's children, etc."""
        flat = [self]
        for child in self.children:
            flat.extend(child.flatten())
        return flat

    @classmethod
    def get(cls, path):

        if isinstance(path, unicode):
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
                q = meta.Session.query(cls).filter_by(title=title_full)
                if hierarchy:
                    q = q.filter_by(parent=tag)
                tag =  q.one()
            except NoResultFound:
                try:
                    q = meta.Session.query(cls).filter_by(title_short=title_full)
                    if hierarchy:
                        q = q.filter_by(parent=tag)
                    tag =  q.one()
                except NoResultFound:
                    tag = None
                    break
        return tag

    @classmethod
    def get_all(cls, title):
        items = meta.Session.query(cls).filter(or_(LocationTag.title==title, LocationTag.title_short==title.upper())).all()
        items.extend(meta.Session.query(cls).filter_by(title_short=title).all())
        return items


group_files_table = None

class File(ContentItem):
    """Class representing user-uploaded files."""

    @property
    def file_parent(self):
        sft = subject_files_table
        subject = meta.Session.query(Subject)\
            .join((sft, sft.c.subject_id==subjects_table.c.id))\
            .filter(sft.c.file_id==self.id).first()

        gft = group_files_table
        group = meta.Session.query(Group)\
            .join((gft, gft.c.group_id==groups_table.c.id))\
            .filter(gft.c.file_id==self.id).first()

        from ututi.model.mailing import group_mailing_list_attachments_table as mft
        from ututi.model.mailing import group_mailing_list_messages_table
        message = meta.Session.query(GroupMailingListMessage)\
            .join(mft)\
            .filter(mft.c.file_id==self.id).first()

        if subject:
            return subject
        if group:
            return group
        if message:
            return message

    def can_write(self, user=None):
        can_write = False
        if isinstance(self.file_parent, Subject):
            can_write = check_crowds(['moderator'], context=self.file_parent, user=user)
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

        self.filename = filename
        self.title = title
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

    def url(self, controller='files', action='get'):
        from ututi.model.mailing import GroupMailingListMessage

        if isinstance(self.file_parent, Subject):
            return self.file_parent.url(controller='subjectfile',
                                   action=action,
                                   file_id=self.id)
        elif isinstance(self.file_parent, Group):
            return self.file_parent.url(controller='groupfile',
                                   action=action,
                                   file_id=self.id)
        elif isinstance(self.file_parent, GroupMailingListMessage):
            message = self.file_parent
            return message.group.url(controller='groupforum',
                                     action='file',
                                     message_id=message.id,
                                     file_id=self.id)
        raise AttributeError("Can't generate url for the file without a parent!")

    def hash_chunked(self, file):
        """Calculate the checksum of a file in chunks."""
        chunk_size = 8 * 1024**2
        size = 0
        hash = hashlib.md5()

        while True:
            if isinstance(file, str):
                chunk = file[size:(size+chunk_size)]
            else:
                chunk = file.read(chunk_size)

            size += len(chunk)
            hash.update(chunk)
            if len(chunk) < chunk_size:
                break

        if not isinstance(file, str):
            file.seek(0)

        return hash.hexdigest()

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
