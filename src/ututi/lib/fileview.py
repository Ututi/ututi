from pylons.templating import render_mako_def

from pylons.controllers.util import abort
from pylons import request, tmpl_context as c
from ututi.model import File, meta

from mimetools import choose_boundary




class FileViewMixin(object):

    def _create_folder(self, obj):
        folder_name = request.params['folder']
        if not folder_name:
            return None
        section_id = request.params.get('section_id', '')
        obj.files.append(File.makeNullFile(folder_name))
        meta.Session.commit()
        for f in obj.folders:
            if f.title == folder_name:
                folder = f
        fid = "_".join(choose_boundary().split(".")[-3:])
        return (render_mako_def('/sections/files.mako','folder_button',
                                folder=folder, section_id=section_id, fid=fid) +
                render_mako_def('/sections/files.mako','folder',
                                folder=folder, section_id=section_id, fid=fid))

    def _delete_folder(self, obj):
        folder_name = request.params['folder']
        for file in list(obj.files):
            if file.folder == folder_name and file.deleted is None:
                file.deleted = c.user
        meta.Session.commit()

    def _upload_file_basic(self, obj):
        from ututi.model import Group
        if isinstance(obj, Group) and not obj.has_file_area:
            return None

        file = request.params['attachment']
        folder = request.params['folder']
        if obj.upload_status != obj.LIMIT_REACHED:
            if file is not None and file != '':
                f = File(file.filename,
                         file.filename,
                         mimetype=file.type)
                f.store(file.file)
                f.folder = folder
                obj.files.append(f)
                meta.Session.add(f)
                meta.Session.commit()
                return f
        else:
            return None

    def _upload_file(self, obj):
        f = self._upload_file_basic(obj)
        if f is not None:
            return render_mako_def('/sections/files.mako','file', file=f, new_file=True)
        else:
            return 'UPLOAD_FAILED'

    def _upload_file_short(self, obj):
        f = self._upload_file_basic(obj)
        return render_mako_def('/portlets/group.mako','portlet_file', file=f)
