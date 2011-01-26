"""Pylons application test package
"""
import sys
import random
import shutil
import urllib

from zope.testbrowser.browser import Link
from mechanize._mechanize import LinkNotFoundError
from nous.pylons.testing import LayerBase, CompositeLayer
from nous.pylons.testing import PylonsTestBrowserLayer
from nous.pylons.grok.testing import GrokLayer

import pylons.test

from nous.pylons.testing.browser import NousTestBrowser, NousTestApp

from ututi.model import LocationTag
from ututi.model import teardown_db_defaults
from ututi.model import initialize_db_defaults
from ututi.model import meta
from ututi.lib.sms import sms_queue
from ututi.lib.mailer import mail_queue
from ututi.lib import gg

import os
here_dir = os.path.dirname(os.path.abspath(__file__))
conf_dir = os.path.dirname(os.path.dirname(os.path.dirname(here_dir)))


class UtutiBaseLayer(LayerBase):

    def tearDown(self):
        try:
            shutil.rmtree(pylons.test.pylonsapp.config['files_path'])
        except OSError:
            pass

    def testSetUp(self):
        teardown_db_defaults(meta.engine, quiet=True)
        initialize_db_defaults(meta.engine)

        config = pylons.test.pylonsapp.config
        config['tpl_lang'] = 'lt'
        mail_queue[:] = []
        sms_queue[:] = []
        gg.sent_messages[:] = []
        try:
            shutil.rmtree(config['files_path'])
        except OSError:
            pass
        os.makedirs(config['files_path'])
        # Keep random stable in tests
        random.seed(123)

    def testTearDown(self):
        config = pylons.test.pylonsapp.config
        if len(gg.sent_messages) > 0:
            print >> sys.stderr, "\n===\nGG queue is NOT EMPTY!"

        if len(mail_queue) > 0:
            print >> sys.stderr, "\n===\nMail queue is NOT EMPTY!"

        if len(sms_queue) > 0:
            print >> sys.stderr, "\n===\nSMS queue is NOT EMPTY!"

        shutil.rmtree(config['files_path'])

        # XXX Tear down database here
        meta.Session.execute("SET ututi.active_user TO 0")
        meta.Session.close()

        teardown_db_defaults(meta.engine)
        meta.Session.rollback()
        meta.Session.remove()


UtutiLayer = CompositeLayer(GrokLayer,
                            PylonsTestBrowserLayer('test.ini', conf_dir, meta),
                            UtutiBaseLayer(),
                            name='UtutiLayer')


UtutiErrorsLayer = CompositeLayer(GrokLayer,
                                  PylonsTestBrowserLayer('errors.ini', conf_dir, meta),
                                  UtutiBaseLayer(),
                                  name='UtutiErrorsLayer')


class UtutiTestBrowser(NousTestBrowser):

    app = None

    def click(self, text, name=None, url=None, id=None, index=0):
        controls = []
        if url is not None or id is not None:
            controls.append(self.getLink(text, url, id, index))
        elif name is not None:
            controls.append(self.getControl(text, name, index))
        else:
            try:
                controls.append(self.getControl(text, name, index))
            except LookupError:
                pass
            try:
                controls.append(self.getLink(text, url, id, index))
            except LinkNotFoundError:
                pass

            if not controls:
                raise LinkNotFoundError()
            elif len(controls) > 1:
                return controls
            control = controls[0]

            # XXX work around url quoting bug in our testing infrastructure
            if isinstance(control, Link):
                control.mech_link.absolute_url = urllib.unquote(control.mech_link.absolute_url)

            return control.click()

    def printCssQuery(self, query, **kwargs):
        return self.printQuery(query, selector='cssselect', **kwargs)

    def printQuery(self, query, **kwargs):
        strip = kwargs.pop('strip', False)
        if strip:
            kwargs['include_attributes'] = ['']
        return super(UtutiTestBrowser, self).printQuery(query, **kwargs)

    @classmethod
    def logIn(cls, email='admin@ututi.lt', password='asdasd'):
        browser = cls()
        form = browser.getForm('loginForm')
        form.getControl('Email').value = email
        form.getControl('Password').value = password
        form.getControl('Login').click()

        browser.app = NousTestApp(pylons.test.pylonsapp)
        res = browser.app.post("/login", params={'login': email, 'password': password})

        if email == 'admin@ututi.lt' and password == 'asdasd':
            browser.open('http://localhost/admin/login')
            browser.getControl('Username').value = email
            browser.getControl('Password').value = password
            browser.getControl('Login').click()
            res = browser.app.post("/admin/join_login", params={'login_username': email,
                                                           'login_password': password})
        browser.open('http://localhost')
        return browser


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser
    # Common test setup, here for backwards compatibility only, will
    # get removed or moved later
    meta.Session.execute("insert into users (fullname, password) values ('Adminas Adminovix', 'xnIVufqLhFFcgX+XjkkwGbrY6kBBk0vvwjA7')")
    meta.Session.execute("insert into emails (id, email, confirmed) values (1, 'admin@ututi.lt', true)")

    l = LocationTag(u'Vilniaus universitetas', u'vu', u'Seniausias universitetas Lietuvoje.')
    f = LocationTag(u'Ekonomikos fakultetas', u'ef', u'', l)
    meta.Session.add(l)
    meta.Session.add(f)


def tearDown(test):
    del test.globs['app']
    del test.globs['Browser']
