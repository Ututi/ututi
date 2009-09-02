"""Pylons application test package
"""
import sys
import re
import random
import webbrowser
import tempfile
import shutil
from lxml import etree
import wsgi_intercept

from wsgi_intercept.zope_testbrowser.wsgi_testbrowser import WSGI_Browser
from wsgi_intercept.urllib2_intercept import uninstall_opener
from wsgi_intercept.urllib2_intercept import install_opener
from wsgiref.simple_server import make_server
from paste.deploy import loadapp
from pylons import config, url
from routes.util import URLGenerator
from webtest import TestApp
from paste.script.appinstall import SetupCommand

from zope.testing.server import addPortToURL
from zope.component.testing import setUp as zcSetUp, tearDown as zcTearDown
from zope.component.eventtesting import PlacelessSetup as EventPlacelessSetup

import pylons.test
from pylons.i18n.translation import _get_translator
from pylons import config
from ututi.model import teardown_db_defaults
from ututi.model import initialize_db_defaults
from ututi.model import meta
from ututi.lib.mailer import mail_queue

__all__ = ['environ', 'url']

environ = {}

import os
here_dir = os.path.dirname(os.path.abspath(__file__))
conf_dir = os.path.dirname(os.path.dirname(os.path.dirname(here_dir)))


class PylonsLayer(object):

    @classmethod
    def setUp(self):
        # Zope component setup
        zcSetUp()
        EventPlacelessSetup().setUp()

        if pylons.test.pylonsapp is None:
            SetupCommand('setup-app').run([conf_dir + '/test.ini'])
            pylons.test.pylonsapp = loadapp('config:test.ini',
                                            relative_to=conf_dir)
            config['files_path'] = tempfile.mkdtemp(prefix="uploads_")
            def create_fn():
                return pylons.test.pylonsapp
            install_opener()
            wsgi_intercept.add_wsgi_intercept('localhost', 80, create_fn)

    @classmethod
    def tearDown(self):
        try:
            shutil.rmtree(config['files_path'])
        except OSError:
            pass
        # Zope component tear down
        zcTearDown()
        pylons.test.pylonsapp = None
        wsgi_intercept.remove_wsgi_intercept()
        uninstall_opener()

    @classmethod
    def testSetUp(self):
        translator = _get_translator(pylons.config.get('lang'))
        pylons.translator._push_object(translator)
        url._push_object(URLGenerator(config['routes.map'], environ))
        # XXX Set up database here
        # meta.metadata.create_all(meta.engine)
        teardown_db_defaults(meta.engine, quiet=True)
        meta.Session.execute("SET ututi.active_user TO 0")
        initialize_db_defaults(meta.engine)
        mail_queue[:] = []
        try:
            shutil.rmtree(config['files_path'])
        except OSError:
            pass
        os.makedirs(config['files_path'])
        # Keep random stable in tests
        random.seed(123)

    @classmethod
    def testTearDown(self):
        url._pop_object()
        pylons.translator._pop_object()
        meta.Session.execute("SET ututi.active_user TO 0")
        meta.Session.close()
        # XXX Tear down database here
        teardown_db_defaults(meta.engine)
        meta.Session.rollback()
        meta.Session.remove()

        if len(mail_queue) > 0:
            print >> sys.stderr, "Mail queue is NOT EMPTY!"

        shutil.rmtree(config['files_path'])


class UtutiTestApp(TestApp):

    request = None

    def do_request(self, req, status, expect_errors):
        self.request = req
        return super(UtutiTestApp, self).do_request(req, status, expect_errors)

    def serve(self):
        try:
            page_url = getattr(self.request, 'url', 'http://localhost/')
            # XXX we rely on browser being slower than our server
            webbrowser.open(addPortToURL(page_url, 5001))
            print >> sys.stderr, 'Starting HTTP server...'
            srv = make_server('localhost', 5001, pylons.test.pylonsapp)
            srv.serve_forever()
        except KeyboardInterrupt:
            print >> sys.stderr, 'Stopped HTTP server.'


def indent(elem, level=0):
    """Function that properly indents xml.

    Stolen from http://infix.se/2007/02/06/gentlemen-indent-your-xml
    """
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        for e in elem:
            indent(e, level+1)
            if not e.tail or not e.tail.strip():
                e.tail = i + "  "
        if not e.tail or not e.tail.strip():
            e.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


def to_string(node):
    if isinstance(node, basestring):
        return node
    else:
        indent(node)
        return etree.tostring(node, pretty_print=True).rstrip()


class Browser(WSGI_Browser):

    @classmethod
    def logIn(cls, email='admin@ututi.lt', password='asdasd'):
        browser = cls()
        form = browser.getForm('login_form')
        form.getControl('Email').value = email
        form.getControl('Password').value = password
        form.getControl('Login').click()
        return browser

    def __init__(self, url='http://localhost/'):
        super(Browser, self).__init__()
        self.handleErrors = False
        self.open(url)

    def serve(self):
        try:
            # XXX we rely on browser being slower than our server
            webbrowser.open(addPortToURL(self.url, 5001))
            print >> sys.stderr, 'Starting HTTP server...'
            srv = make_server('localhost', 5001, pylons.test.pylonsapp)
            srv.serve_forever()
        except KeyboardInterrupt:
            print >> sys.stderr, 'Stopped HTTP server.'

    def printContents(self):
        normal_body_regex = re.compile(r'[ \n\r\t]+')
        print normal_body_regex.sub(' ', self.contents)

    def queryHTML(self, query):
        doc = etree.HTML(self.contents)
        result = [to_string(node) for node in doc.xpath(query)]
        return result

    def printQuery(self, query):
        for item in self.queryHTML(query):
            print item


def setUp(test):
    test.globs['app'] = UtutiTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = Browser


def tearDown(test):
    del test.globs['app']
    del test.globs['Browser']
