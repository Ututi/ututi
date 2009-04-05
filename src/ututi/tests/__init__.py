"""Pylons application test package
"""
from paste.deploy import loadapp
from pylons import config, url
from routes.util import URLGenerator
from webtest import TestApp

from zope.component.testing import setUp as zcSetUp, tearDown as zcTearDown
from zope.component.eventtesting import PlacelessSetup as EventPlacelessSetup

import pylons.test
from pylons.i18n.translation import _get_translator

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

    @classmethod
    def testTearDown(self):
        url._pop_object()
        pylons.translator._pop_object()
        # XXX Tear down database here


def setUp(test):
    test.globs['app'] = TestApp(pylons.test.pylonsapp)


def tearDown(test):
    del test.globs['app']
