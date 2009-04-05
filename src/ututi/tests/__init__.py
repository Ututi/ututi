"""Pylons application test package

This package assumes the Pylons environment is already loaded, such as
when this script is imported from the `nosetests --with-pylons=test.ini`
command.

This module initializes the application via ``websetup`` (`paster
setup-app`) and provides the base testing objects.
"""
from unittest import TestCase

from paste.deploy import loadapp
from paste.script.appinstall import SetupCommand
from pylons import config, url
from routes.util import URLGenerator
from webtest import TestApp

import pylons.test

__all__ = ['environ', 'url', 'TestController']

# Invoke websetup with the current config file
SetupCommand('setup-app').run(['test.ini'])

environ = {}

def setUp():
    if pylons.test.pylonsapp:
        wsgiapp = pylons.test.pylonsapp
    else:
        pylons.test.pylonsapp = wsgiapp = loadapp('config:test.ini')

    # Initialize a translator for tests that utilize i18n
    from pylons.i18n.translation import _get_translator
    translator = _get_translator(pylons.config.get('lang'))
    pylons.translator._push_object(translator)
    url._push_object(URLGenerator(config['routes.map'], environ))

import os
here_dir = os.path.dirname(os.path.abspath(__file__))
conf_dir = os.path.dirname(os.path.dirname(os.path.dirname(here_dir)))


class TestController(TestCase):

    def __init__(self, *args, **kwargs):
        if pylons.test.pylonsapp:
            wsgiapp = pylons.test.pylonsapp
        else:
            wsgiapp = loadapp('config:test.ini', relative_to=conf_dir)
        # Initialize a translator for tests that utilize i18n
        from pylons.i18n.translation import _get_translator
        translator = _get_translator(pylons.config.get('lang'))
        pylons.translator._push_object(translator)
        self.app = TestApp(wsgiapp)
        url._push_object(URLGenerator(config['routes.map'], environ))
        TestCase.__init__(self, *args, **kwargs)

class UnitLayer1(object):

    @classmethod
    def setUp(self):
        if pylons.test.pylonsapp:
            wsgiapp = pylons.test.pylonsapp
        else:
            pylons.test.pylonsapp = wsgiapp = loadapp('config:/home/ignas/src/schooltool/pylons/ututi/test.ini')

    @classmethod
    def tearDown(self):
        pass

    @classmethod
    def testSetUp(self):
        """This method is run before each single test in the current
        layer. It is optional.
        """
        print "    Running testSetUp of UnitLayer1"

    @classmethod
    def testTearDown(self):
        """This method is run before each single test in the current
        layer. It is optional.
        """
        print "    Running testTearDown of UnitLayer1"

