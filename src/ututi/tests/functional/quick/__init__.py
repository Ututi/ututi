#
import pylons.test

from nous.pylons.testing.browser import NousTestApp

from ututi.tests import UtutiTestBrowser
from ututi.model import LocationTag
from ututi.model import meta


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser
    res = meta.Session.execute("select * from users where id = 1")
    if not list(res):
        meta.Session.execute("insert into users (fullname, password) values ('Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7')")
        meta.Session.execute("insert into emails (id, email, confirmed)"
                             " (select users.id, 'admin@ututi.lt', true from users where fullname = 'Adminas Adminovix')")

    l = LocationTag(u'Vilniaus universitetas', u'vu', u'Seniausias universitetas Lietuvoje.')
    f = LocationTag(u'Ekonomikos fakultetas', u'ef', u'', l)
    meta.Session.add(l)
    meta.Session.add(f)
    meta.Session.commit()


def tearDown(test):
    meta.Session.execute("truncate tags cascade")
    meta.Session.execute("truncate content_items cascade")
    meta.Session.commit()
