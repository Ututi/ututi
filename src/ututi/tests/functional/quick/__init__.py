#
import pylons.test

from nous.pylons.testing.browser import NousTestApp

from ututi.tests import UtutiTestBrowser
from ututi.tests.data import create_user
from ututi.model import LocationTag
from ututi.model import meta


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser
    l = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    f = LocationTag(u'D-epartment', u'dep', u'', l, member_policy='PUBLIC')
    meta.Session.add(l)
    meta.Session.add(f)
    meta.Session.commit()

    res = meta.Session.execute("select * from users where id = 1")
    if not list(res):
        create_user()

        # User with second email
        create_user('Some user', 'second@mif.stud.vu.lt', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7', 'uni', 'second@gmail.com')

    meta.Session.commit()


def tearDown(test):
    meta.Session.execute("truncate notifications cascade")
    meta.Session.execute("truncate tags cascade")
    meta.Session.execute("truncate regions cascade")
    meta.Session.execute("truncate content_items cascade")
    meta.Session.execute("truncate authors cascade")
    meta.Session.execute("truncate i18n_texts cascade")
    relnames = meta.Session.query('relname').from_statement(
               "select relname from pg_class where relkind = 'S'")
    for name, in relnames:
        if not name.startswith('admin_users'):
            meta.Session.execute('alter sequence %s restart with 1' % name)
    meta.Session.commit()
