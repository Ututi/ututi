"""Pylons application test package
"""
import sys
import webbrowser
import pkg_resources

from wsgiref.simple_server import make_server
from paste.deploy import loadapp
from pylons import config, url
from routes.util import URLGenerator
from webtest import TestApp

from zope.testing.server import addPortToURL
from zope.component.testing import setUp as zcSetUp, tearDown as zcTearDown
from zope.component.eventtesting import PlacelessSetup as EventPlacelessSetup

import pylons.test
from pylons.i18n.translation import _get_translator

from ututi.model import teardown_db_defaults
from ututi.model import setup_orm
from ututi.model import initialize_db_defaults
from ututi.model import meta

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
            pylons.test.pylonsapp = loadapp('config:test.ini',
                                            relative_to=conf_dir)


    @classmethod
    def tearDown(self):
        # Zope component tear down
        zcTearDown()

        pylons.test.pylonsapp = None

    @classmethod
    def testSetUp(self):
        translator = _get_translator(pylons.config.get('lang'))
        pylons.translator._push_object(translator)
        url._push_object(URLGenerator(config['routes.map'], environ))
        # XXX Set up database here
        # meta.metadata.create_all(meta.engine)
        initialize_db_defaults(meta.engine)

    @classmethod
    def testTearDown(self):
        url._pop_object()
        pylons.translator._pop_object()
        # XXX Tear down database here
        teardown_db_defaults(meta.engine)
        meta.Session.remove()


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


def setUp(test):
    test.globs['app'] = UtutiTestApp(pylons.test.pylonsapp)


def tearDown(test):
    del test.globs['app']
