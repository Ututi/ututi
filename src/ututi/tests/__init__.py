"""Pylons application test package
"""
import sys
import random
import shutil
import urllib
import atexit

from wsgi_intercept.zope_testbrowser.wsgi_testbrowser import WSGI_Browser
from lxml.cssselect import ExpressionError
from lxml.html import fromstring
from zope.testbrowser.browser import Link
from mechanize._mechanize import LinkNotFoundError
from nous.pylons.testing import LayerBase, CompositeLayer
from nous.pylons.testing import PylonsTestBrowserLayer
from nous.pylons.grok.testing import GrokLayer

import pylons.test

from nous.pylons.testing.browser import NousTestBrowser, NousTestApp

from ututi.model import teardown_db_defaults
from ututi.model import initialize_db_defaults
from ututi.model import meta
from ututi.lib.sms import sms_queue
from ututi.lib.mailer import mail_queue
from ututi.lib import gg
from ututi.tests.css_rules import get_all_rules

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
        meta.Session.close()

        teardown_db_defaults(meta.engine)
        meta.Session.rollback()
        meta.Session.remove()


class UtutiQuickLayerBase(LayerBase):

    def setUp(self):
        teardown_db_defaults(meta.engine, quiet=True)
        initialize_db_defaults(meta.engine)

    def tearDown(self):
        try:
            shutil.rmtree(pylons.test.pylonsapp.config['files_path'])
        except OSError:
            pass
        teardown_db_defaults(meta.engine)

    def testSetUp(self):
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
        meta.Session.close()

        meta.Session.rollback()
        meta.Session.remove()


UtutiLayer = CompositeLayer(GrokLayer,
                            PylonsTestBrowserLayer('test.ini', conf_dir, meta),
                            UtutiBaseLayer(),
                            name='UtutiLayer')

UtutiFunctionalLayer = CompositeLayer(GrokLayer,
                                      PylonsTestBrowserLayer('test.ini', conf_dir, meta),
                                      UtutiBaseLayer(),
                                      name='UtutiFunctionalLayer')

U2tiFunctionalLayer = CompositeLayer(GrokLayer,
                                     PylonsTestBrowserLayer('test2.ini', conf_dir, meta),
                                     UtutiBaseLayer(),
                                     name='U2tiFunctionalLayer')

UtutiErrorsLayer = CompositeLayer(GrokLayer,
                                  PylonsTestBrowserLayer('errors.ini', conf_dir, meta),
                                  UtutiQuickLayerBase(),
                                  name='UtutiErrorsLayer')


UtutiQuickLayer = CompositeLayer(GrokLayer,
                                 PylonsTestBrowserLayer('test.ini', conf_dir, meta),
                                 UtutiQuickLayerBase(),
                                 name='UtutiQuickLayer')

U2tiQuickLayer = CompositeLayer(GrokLayer,
                                 PylonsTestBrowserLayer('test2.ini', conf_dir, meta),
                                 UtutiQuickLayerBase(),
                                 name='U2tiQuickLayer')


class UtutiTestBrowser(NousTestBrowser):

    app = None

    def __init__(self, url='http://localhost/'):
        # XXX this is a workaround for a but in NousTestBrowser, it
        # can't handle url not being passed to the constructor
        WSGI_Browser.__init__(self)
        self.handleErrors = False
        if url is not None:
            self.open(url)

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
    def logIn(cls, email='admin@uni.ututi.com', password='asdasd', location='uni'):
        browser = cls()
        browser.open('http://localhost/school/%s/login' % location)
        form = browser.getForm('login-form')
        form.getControl('Your email address').value = email
        form.getControl('Password').value = password
        form.getControl('Login').click()

        browser.app = NousTestApp(pylons.test.pylonsapp)
        browser.app.post('http://localhost/school/%s/login' % location,
                         params={'login': email, 'password': password})

        if email == 'admin@uni.ututi.com' and password == 'asdasd':
            admin_email = 'admin@ututi.lt'
            browser.open('http://localhost/admin/login')
            form = browser.getForm('adminLoginForm')
            form.getControl('Username').value = admin_email
            form.getControl('Password').value = password
            form.getControl('Login').click()
            browser.app.post("/admin/join_login", params={'login_username': admin_email,
                                                          'login_password': password})
        browser.open('http://localhost')
        return browser

    _rules = get_all_rules()

    def rules(self):
        return self._rules

    def remove_rule(self, rule):
        self._rules.remove(rule)

    def check_rules(self):
        try:
            doc = fromstring(self.contents)
        except:
            return
        for css_file, rule in self.rules():
            try:
                nodes = doc.cssselect(rule)
            except:
                print >> sys.stderr, "XXX", css_file, rule
                nodes = ['']

            if len(nodes) > 0:
                print >> sys.stderr, "Found %s %r in %s" % (css_file, rule, self.url)
                self.remove_rule((css_file, rule))

    def _changed(self):
        if os.environ.get('TESTCSS'):
            self.check_rules()
        self._counter += 1
        self._contents = None

    @classmethod
    def printRules(cls):
        for css_file, rule in sorted(cls._rules):
            print css_file, rule


if os.environ.get('TESTCSS'):
    atexit.register(UtutiTestBrowser.printRules)


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser


def tearDown(test):
    del test.globs['app']
    del test.globs['Browser']
