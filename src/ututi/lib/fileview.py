from pylons.templating import render_mako_def

from pylons import request
from ututi.model import File, meta

from mimetools import choose_boundary


class FileViewMixin(object):

    def _create_folder(self, obj):
        folder_name = request.POST['folder']
        section_id = request.POST['section_id']
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
        folder_name = request.POST['folder']
        for file in list(obj.files):
            if file.folder == folder_name:
                obj.files.remove(file)
                meta.Session.delete(file)
        meta.Session.commit()

    def _upload_file(self, obj):
        file = request.POST['attachment']
        folder = request.POST['folder']
        if file is not None and file != '':
            f = File(file.filename,
                     file.filename,
                     mimetype=file.type)
            f.store(file.file)
            f.folder = folder
            obj.files.append(f)
            meta.Session.add(f)
            meta.Session.commit()
        return render_mako_def('/sections/files.mako','file', file=f)
