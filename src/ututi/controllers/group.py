import re
import logging
from datetime import date
from os.path import splitext

from pylons import c, request, config
from pylons.controllers.util import redirect_to, abort
from pylons.decorators import validate
from pylons.i18n import _

from formencode import Schema, validators, Invalid
from sqlalchemy.sql.expression import desc
from sqlalchemy.orm.exc import NoResultFound

from ututi.lib.image import serve_image
from ututi.lib.base import BaseController, render
from ututi.model.mailing import GroupMailingListMessage
from ututi.model import meta, Group, File
from routes import url_for

log = logging.getLogger(__name__)


class GroupIdValidator(validators.FancyValidator):
    """A validator that makes sure the group id is unique."""
    messages = {
        'duplicate': _(u"Such id already exists, choose a different one."),
        'badId': _(u"Id cannot be used as an email address.")
        }

    def _to_python(self, value, state):
        return value.strip()

    def validate_python(self, value, state):
        if value != 0:
            try:
                meta.Session.query(Group).filter_by(id=value).one()
                raise Invalid(self.message('duplicate', state), value, state)
            except NoResultFound:
                pass

            usernameRE = re.compile(r"^[^ \t\n\r@<>()]+$", re.I)
            if not usernameRE.search(value):
                raise Invalid(self.message('badId', state), value, state)


class FileUploadTypeValidator(validators.FancyValidator):
    """ A validator to check uploaded file types."""
    messages = {
        'bad_type': _(u"Bad file type, only files of the types '%(allowed)s' are supported.")
        }
    __unpackargs__ = ('allowed_types')

    def _to_python(self, value, state):
        if hasattr(value, 'filename'):
            return splitext(value.filename)[1].lower()
        return None

    def validate_python(self, value, state):
        if value is not None:
            if value not in self.allowed_types:
                raise Invalid(self.message('bad_type', state, allowed=', '.join(self.allowed_types)), value, state)


class NewGroupForm(Schema):
    """A schema for validating new group forms."""
    allow_extra_fields = True

    id = GroupIdValidator()
    logo_upload = validators.FieldStorageUploadConverter(not_empty=False)
    title = validators.String(not_empty=True)

class EditGroupForm(Schema):
    """A schema for validating group edits."""
    allow_extra_fields = True
    title = validators.String(not_empty=True)
    logo_upload = FileUploadTypeValidator(allowed_types=('.jpg', '.png', '.bmp', '.tiff', '.jpeg', '.gif'))


def group_action(method):
    def _group_action(self, id):
        group = Group.get(id)
        if group is None:
            abort(404)
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group)
    return _group_action


def group_forum_action(method):
    def _group_action(self, id, thread_id):
        group = Group.get(id)
        if group is None:
            abort(404)
        thread = meta.Session.query(GroupMailingListMessage).filter_by(id=thread_id).first()
        if (thread is None or
            thread.thread != thread or
            thread.group != group):
            abort(404)
        c.breadcrumbs = [{'title': group.title, 'link': group.url()}]
        return method(self, group, thread)
    return _group_action


class GroupController(BaseController):
    """Controller for group actions."""

    def __before__(self):
        c.breadcrumbs = [
            {'title': _('Groups'),
             'link': url_for(controller='group', action='index')}
            ]
        c.mailing_list_host = config.get('mailing_list_host', '')

    def _actions(self, selected):
        """
        A method to generate the list of all possible group actions. The selected action is indicated
        by its name.
        """
        return [
            {'title': _('Home'),
             'link': url_for(controller='group', action='group_home', id=c.group.id),
             'selected': selected == 'group_home'},
            {'title': _('Forum'),
             'link': url_for(controller='group', action='forum', id=c.group.id),
             'selected': selected == 'forum'},
            {'title': _('Members'),
             'link': url_for(controller='group', action='members', id=c.group.id),
             'selected': selected == 'members'},
            {'title': _('Files'),
             'link': url_for(controller='group', action='files', id=c.group.id),
             'selected': selected == 'files'},
            ]

    def index(self):
        c.groups = meta.Session.query(Group).all()
        return render('groups.mako')

    @group_action
    def group_home(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('group_home'))
        return render('group/home.mako')

    def _top_level_messages(self, group):
        messages = []
        for message in meta.Session.query(GroupMailingListMessage)\
                .filter_by(group_id=group.id, reply_to=None)\
                .order_by(desc(GroupMailingListMessage.sent))\
                .all():
            msg = {'thread_id': message.id,
                   'last_reply_author_id': message.posts[-1].author.id,
                   'last_reply_author_title': message.posts[-1].author.fullname,
                   'last_reply_date': message.posts[-1].sent,
                   'reply_count': len(message.posts) - 1,
                   'subject': message.subject}
            messages.append(msg)
        return messages

    @group_action
    def forum(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('forum'))
        c.messages = self._top_level_messages(group)
        return render('group/forum.mako')

    @group_forum_action
    def forum_thread(self, group, thread):
        c.group = group
        c.breadcrumbs.append(self._actions('forum'))
        c.messages = thread.posts
        return render('group/thread.mako')

    @group_action
    def files(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('files'))
        return render('group/files.mako')

    def add(self):
        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group/add.mako')

    @validate(schema=NewGroupForm, form='add')
    def new_group(self):
        fields = ('id', 'title', 'description', 'year', 'logo_upload')
        values = {}
        for field in fields:
             values[field] = request.POST.get(field, None)

        group = Group(id=values['id'],
                      title=values['title'],
                      description=values['description'],
                      year=date(int(values['year']), 1, 1))
        meta.Session.add(group)

        if values['logo_upload'] is not None and values['logo_upload'] != '':
            logo = values['logo_upload']
            f = File(logo.filename, 'Logo for group %s' % group.title, mimetype=logo.type)
            f.store(logo.file)
            meta.Session.add(f)
            group.logo = f

        meta.Session.commit()

        redirect_to(controller='group', action='group_home', id=values['id'])

    @group_action
    def members(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('members'))
        return render('group/members.mako')

    @group_action
    def edit(self, group):
        c.group = group
        c.breadcrumbs.append(self._actions('group_home'))

        c.current_year = date.today().year
        c.years = range(c.current_year - 10, c.current_year + 5)
        return render('group/edit.mako')

    @validate(EditGroupForm, form='edit')
    @group_action
    def update(self, group):
        fields = ('title', 'year', 'description', 'logo_upload', 'logo_delete')
        values = {}

        for field in fields:
            values[field] = request.POST.get(field, None)

        group.title = values['title']
        group.year = date(int(values['year']), 1, 1)
        group.description = values['description']

        if values['logo_delete'] == 'delete' and group.logo is not None:
            meta.Session.delete(group.logo)
            group.logo = None

        if values['logo_upload'] is not None and values['logo_upload'] != '':
            logo = values['logo_upload']
            f = File(logo.filename, u'Logo for group %s' % group.title, mimetype=logo.type)
            f.store(logo.file)
            meta.Session.add(f)

            if group.logo is not None:
                meta.Session.delete(group.logo)
            group.logo = f

        meta.Session.commit()
        redirect_to(controller='group', action='group_home', id=group.id)


    def logo(self, id, width=None, height=None):
        group = Group.get(id)
        return serve_image(group.logo, width=width, height=height)
