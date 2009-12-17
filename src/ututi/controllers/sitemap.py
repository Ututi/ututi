from pylons import c, config

from ututi.lib.base import BaseController, render
from ututi.model import meta, Subject, LocationTag, Group

class SitemapController(BaseController):

    def index(self):
        c.file_limit = int(config.get('small_file_size', 1024**2))
        c.schools = meta.Session.query(LocationTag).filter(LocationTag.parent == None).order_by(LocationTag.title_short.asc()).all()
        c.subjects = meta.Session.query(Subject).filter_by(deleted_by=None).order_by(Subject.title.asc()).all()
        c.groups = meta.Session.query(Group).filter_by(deleted_by=None).order_by(Group.title.asc()).all()
        return render('sitemap/index.mako',
                      cache_key='sitemap', cache_expire=7*24*3600, cache_type='file')
