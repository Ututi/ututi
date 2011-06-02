import logging

from sqlalchemy.orm.exc import NoResultFound

from pylons import tmpl_context as c, url
from pylons.controllers.util import abort

from ututi.controllers.files import BasefilesController
from ututi.model import Subject, File, LocationTag
from ututi.model import meta
from ututi.lib.security import ActionProtector

from pylons.i18n import _

log = logging.getLogger(__name__)


def set_login_url(method):
    def _set_login_url(self, subject, file):
        c.login_form_url = url(controller='home',
                               action='login',
                               came_from=subject.url(action='files', serve_file=file.id),
                               context=file.filename)
        return method(self, subject, file)
    return _set_login_url


def subject_file_action(method):
    def _subject_action(self, id, tags, file_id):
        location = LocationTag.get(tags)
        subject = Subject.get(location, id)

        if subject is None:
            abort(404)

        file = File.get(file_id)
        if file is None:
            abort(404)

        if (file not in subject.files
            and not file.can_write()):
            abort(404)

        c.object_location = subject.location
        c.security_context = file
        c.subject = subject
        c.theme = subject.location.get_theme()
        return method(self, subject, file)
    return _subject_action


class SubjectfileController(BasefilesController):

    @subject_file_action
    @set_login_url
    @ActionProtector('user', 'smallfile')
    def get(self, subject, file):
        return self._get(file)

    @subject_file_action
    @ActionProtector('owner', 'moderator')
    def delete(self, subject, file):
        return self._delete(file)

    @subject_file_action
    @ActionProtector('owner', 'moderator')
    def rename(self, subject, file):
        return self._rename(file)

    @subject_file_action
    @ActionProtector('owner', 'moderator')
    def restore(self, subject, file):
        return self._restore(file)

    @subject_file_action
    @ActionProtector('user')
    def move(self, subject, file):
        return self._move(subject, file)

    @subject_file_action
    @ActionProtector('user')
    def copy(self, subject, file):
        return self._copy(subject, file)

    @subject_file_action
    def flag(self, subject, file):
        return self._flag(file)
