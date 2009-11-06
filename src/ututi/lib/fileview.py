from pylons.templating import render_mako_def

from pylons import request
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
            if file.folder == folder_name:
                obj.files.remove(file)
                meta.Session.delete(file)
        meta.Session.commit()

    def _upload_file_basic(self, obj):
        file = request.params['attachment']
        folder = request.params['folder']
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

    def _upload_file(self, obj):
        f = self._upload_file_basic(obj)
        return render_mako_def('/sections/files.mako','file', file=f, new_file=True)

    def _upload_file_short(self, obj):
        f = self._upload_file_basic(obj)
        return render_mako_def('/portlets/group.mako','portlet_file', file=f)
