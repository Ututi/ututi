#
import pylons.test

from nous.pylons.testing.browser import NousTestApp

from ututi.tests import UtutiTestBrowser
from ututi.model import LocationTag
from ututi.model import meta


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser
    l = LocationTag(u'U-niversity', u'uni', u'')
    f = LocationTag(u'D-epartment', u'dep', u'', l)
    meta.Session.add(l)
    meta.Session.add(f)
    meta.Session.commit()

    res = meta.Session.execute("select * from users where id = 1")
    if not list(res):
        meta.Session.execute("insert into users (location_id, username, fullname, password)"
                             " (select tags.id, 'admin@uni.ututi.com', 'Administrator of the university', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7'"
                             " from tags where title_short = 'uni');")
        meta.Session.execute("insert into emails (id, email, confirmed)"
                             " (select users.id, users.username, true from users where fullname = 'Administrator of the university')")
    meta.Session.commit()


def tearDown(test):
    meta.Session.execute("truncate tags cascade")
    meta.Session.execute("truncate content_items cascade")
    relnames = meta.Session.query('relname').from_statement(
               "select relname from pg_class where relkind = 'S'")
    for name, in relnames:
        if not name.startswith('admin_users'):
            meta.Session.execute('alter sequence %s restart with 1' % name)
    meta.Session.commit()
