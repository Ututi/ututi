"""Pylons application test package
"""
import sys
import random
import shutil

from nous.pylons.testing import LayerBase, CompositeLayer
from nous.pylons.testing import PylonsTestBrowserLayer
from nous.pylons.grok.testing import GrokLayer

import pylons.test

from nous.pylons.testing.browser import NousTestBrowser, NousTestApp

from ututi.model import teardown_db_defaults
from ututi.model import initialize_db_defaults
from ututi.model import meta
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

        shutil.rmtree(config['files_path'])

        # XXX Tear down database here
        meta.Session.execute("SET ututi.active_user TO 0")
        meta.Session.close()

        teardown_db_defaults(meta.engine)
        meta.Session.rollback()
        meta.Session.remove()


UtutiLayer = CompositeLayer(GrokLayer,
                            PylonsTestBrowserLayer('test.ini', conf_dir),
                            UtutiBaseLayer(),
                            name='UtutiLayer')


UtutiErrorsLayer = CompositeLayer(GrokLayer,
                                  PylonsTestBrowserLayer('errors.ini', conf_dir),
                                  UtutiBaseLayer(),
                                  name='UtutiErrorsLayer')


class UtutiTestBrowser(NousTestBrowser):

    app = None

    def printCssQuery(self, query, **kwargs):
        return self.printQuery(query, selector='cssselect', **kwargs)

    @classmethod
    def logIn(cls, email='admin@ututi.lt', password='asdasd'):
        browser = cls()
        form = browser.getForm('loginForm')
        form.getControl('Email').value = email
        form.getControl('Password').value = password
        form.getControl('Login').click()

        browser.app = NousTestApp(pylons.test.pylonsapp)
        res = browser.app.post("/login", params={'login': email, 'password': password})
        return browser


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser


def tearDown(test):
    del test.globs['app']
    del test.globs['Browser']
