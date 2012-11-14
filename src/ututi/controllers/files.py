import logging
import mimetypes
import re

from formencode.schema import Schema
from formencode import htmlfill
from paste.fileapp import FileApp
from paste.util.converters import asbool

from pylons.templating import render_mako_def
from pylons.controllers.util import abort
from pylons import url, config
from pylons import request, response, tmpl_context as c
from pylons.controllers.util import forward, redirect

from ututi.lib.security import deny
from ututi.lib.security import is_root
from ututi.lib.security import check_crowds
from ututi.lib.security import ActionProtector
from ututi.lib.mailer import send_email
from ututi.lib.base import BaseController, render
from ututi.model import meta, File, ContentItem
from ututi.lib.validators import ParentIdValidator, validate
from sqlalchemy.orm.exc import NoResultFound
from pylons.i18n import _
from routes import url_for

log = logging.getLogger(__name__)


class UndeleteForm(Schema):
    """A schema for validating file undelete forms."""

    allow_extra_fields = True
    parent_id = ParentIdValidator()


def serve_file(file, attachment=False):
    headers = [('Content-Disposition', 'attachment; filename="%s"' % file.filename.encode('utf-8'))]
    content_type, content_encoding = mimetypes.guess_type(file.filename.encode('utf-8'))
    kwargs = {'content_type': content_type}
    if content_type in ['image/png', 'image/jpeg'] and not attachment:
        headers = [('Content-Disposition', 'inline; filename="%s"' % file.filename.encode('utf-8'))]
    return forward(FileApp(file.filepath(), headers=headers, **kwargs))


class BasefilesController(BaseController):

    def _get(self, file):
        if file.deleted is not None or file.isNullFile():
            abort(404)

        attachment_mode = 'attachment' in request.params.keys()
        if c.user:
            range_start = None
            range_end = None

            if request.range is not None:
                c_range = request.range.content_range(length=file.filesize)
                if c_range is not None:
                    (range_start, range_end, file_len) = c_range

            c.user.download(file, range_start, range_end)
            meta.Session.commit()
        return serve_file(file, attachment_mode)

    def _delete(self, file):
        file.deleted = c.user
        meta.Session.commit()
        return render_mako_def('/sections/files.mako','file', file=file)

    def _rename(self, file):
        new_file_name = request.params.get('new_file_name', '').strip()
        if new_file_name:
            file.title = new_file_name
        meta.Session.commit()
        return file.title

    def _restore(self, file):
        file.deleted = None
        meta.Session.commit()
        return render_mako_def('/sections/files.mako','file', file=file)

    def _move(self, source, file):
        source_folder = file.folder
        delete = asbool(request.POST.get('remove', False))
        if delete:
            if check_crowds(['owner', 'moderator', 'admin']):
                file.deleted = c.user
            else:
                abort(501)
        else:
            file.folder = request.POST['target_folder']
            file.deleted = None

        if source_folder and source.getFolder(source_folder) is None:
            source.files.append(File.makeNullFile(source_folder))

        meta.Session.commit()
        return render_mako_def('/sections/files.mako','file', file=file)

    def _copy(self, source, file_to_copy):
        target_id = int(request.POST['target_id'])
        target = meta.Session.query(ContentItem).filter_by(id=target_id).one()


        new_file = file_to_copy.copy()
        new_file.folder = request.POST['target_folder']

        target.files.append(new_file)
        meta.Session.commit()

        return render_mako_def('/sections/files.mako','file', file=new_file, new_file=True)

    def _flag(self, file):
        if request.method == 'POST':
            reason = request.POST.get('reason')
            if c.user:
                email = c.user.email.email
            else:
                email = request.POST.get('reporter_email')
            extra_vars = dict(f=file, reason=reason, email=email)
            send_email(config['ututi_email_from'],
                       config['ututi_email_from'],
                       'Flagged file: %s' % file.filename,
                       render('/emails/flagged_file.mako', extra_vars=extra_vars),
                       send_to=[config['ututi_email_from']])
        return htmlfill.render(render_mako_def('/sections/files.mako', 'flag_file', f=file))


class FilesController(BasefilesController):
    """A controller for files. Handles listing, uploads and downloads."""

    def __before__(self):
        c.breadcrumbs = [
            {'link': url_for(controller='files', action='index'),
             'title': _('Files')}
        ]

    @ActionProtector('root')
    def upload(self):
        title = request.POST['title']
        description = request.POST['description']
        file = request.POST['upload']

        if file is not None and file != '':
            f = File(file.filename, title, mimetype=file.type)
            f.store(file.file)

            meta.Session.add(f)
            meta.Session.commit()

        redirect(url(controller='admin', action='files'))

    def get(self, id):
        if isinstance(id, basestring):
            id = re.search(r"\d*", id).group()

        if not id:
            abort(404)

        file = File.get(id)
        if file is None:
            abort(404)
        if file.parent is not None:
            redirect(file.url())
        elif is_root(c.user):
            return self._get(file)
        else:
            c.login_form_url = url(controller='home',
                                   action='login',
                                   came_from=file.url())
            deny(_('You have no right to download this file.'), 403)

    @ActionProtector('root')
    def delete(self, id):
        file = File.get(id)
        if file is None:
            abort(404)
        return self._delete(file)

    @validate(UndeleteForm)
    @ActionProtector('root')
    def undelete(self, id):
        if hasattr(self, 'form_result'):
            parent = self.form_result['parent_id']
            file = File.get(id)
            if file is None:
                abort(404)

            if parent is None:
                if file.parent is None:
                    abort(400)
            else:
                file.parent = parent

            file.deleted_by = None
            meta.Session.commit()
            redirect(url(controller='admin', action='deleted_files'))
        else:
            abort(400) #bad request
