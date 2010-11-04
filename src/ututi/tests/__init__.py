"""Pylons application test package
"""
import sys
import random
import shutil
import wsgi_intercept

from wsgi_intercept.urllib2_intercept import uninstall_opener
from wsgi_intercept.urllib2_intercept import install_opener
from paste.deploy import loadapp
from pylons import url
from routes.util import URLGenerator
from paste.script.appinstall import SetupCommand

from zope.component.testing import setUp as zcSetUp, tearDown as zcTearDown
from zope.component.eventtesting import PlacelessSetup as EventPlacelessSetup

import pylons.test
from pylons.i18n.translation import _get_translator

from nous.pylons.testing.browser import NousTestBrowser, NousTestApp

from ututi.model import teardown_db_defaults
from ututi.model import initialize_db_defaults
from ututi.model import meta
from ututi.lib.mailer import mail_queue
from ututi.lib import gg

__all__ = ['environ', 'url']

environ = {}

import os
here_dir = os.path.dirname(os.path.abspath(__file__))
conf_dir = os.path.dirname(os.path.dirname(os.path.dirname(here_dir)))


def zopeComponentLayerSetUp(cls):
    # Zope component setup
    zcSetUp()
    EventPlacelessSetup().setUp()


def pylonsAppLayerSetUp(cls):
    if pylons.test.pylonsapp is not None:
        raise Exception
    SetupCommand('setup-app').run([conf_dir + '/%s' % cls.config])
    pylons.test.pylonsapp = loadapp('config:%s' % cls.config,
                                    relative_to=conf_dir)


def wsgiInterceptLayerSetUp(cls):
    def create_fn():
        return pylons.test.pylonsapp
    install_opener()
    wsgi_intercept.add_wsgi_intercept('localhost', 80, create_fn)


def wsgiInterceptLayerTearDown(cls):
    wsgi_intercept.remove_wsgi_intercept()
    uninstall_opener()


def pylonsAppLayerTearDown(cls):
    from sqlalchemy.schema import MetaData
    meta.metadata = MetaData()
    from sqlalchemy.orm import clear_mappers
    clear_mappers()
    pylons.test.pylonsapp = None


def zopeComponentLayerTearDown(cls):
    zcTearDown()


def ututiLayerTearDown(cls):
    try:
        shutil.rmtree(pylons.test.pylonsapp.config['files_path'])
    except OSError:
        pass


def layerSetUp(cls):
    zopeComponentLayerSetUp(cls)
    pylonsAppLayerSetUp(cls)
    wsgiInterceptLayerSetUp(cls)


def layerTearDown(cls):
    wsgiInterceptLayerTearDown(cls)
    ututiLayerTearDown(cls)
    pylonsAppLayerTearDown(cls)
    zopeComponentLayerTearDown(cls)


def layerTestSetUp(cls):
    config = pylons.test.pylonsapp.config
    config['tpl_lang'] = 'lt'
    translator = _get_translator(config.get('lang'), pylons_config=config)
    pylons.translator._push_object(translator)
    url._push_object(URLGenerator(pylons.test.pylonsapp.config['routes.map'], environ))
    # XXX Set up database here
    # meta.metadata.create_all(meta.engine)
    teardown_db_defaults(meta.engine, quiet=True)
    initialize_db_defaults(meta.engine)
    mail_queue[:] = []
    gg.sent_messages[:] = []
    try:
        shutil.rmtree(config['files_path'])
    except OSError:
        pass
    os.makedirs(config['files_path'])
    # Keep random stable in tests
    random.seed(123)


def layerTestTearDown(cls):
    config = pylons.test.pylonsapp.config
    url._pop_object()
    pylons.translator._pop_object()
    meta.Session.execute("SET ututi.active_user TO 0")
    meta.Session.close()
    # XXX Tear down database here
    teardown_db_defaults(meta.engine)
    meta.Session.rollback()
    meta.Session.remove()
    from nous.pylons.grok import the_multi_grokker
    the_multi_grokker.clear()
    if len(gg.sent_messages) > 0:
        print >> sys.stderr, "GG queue is NOT EMPTY!"

    if len(mail_queue) > 0:
        print >> sys.stderr, "Mail queue is NOT EMPTY!"

    shutil.rmtree(config['files_path'])


class PylonsLayer(object):

    config = 'test.ini'

    @classmethod
    def setUp(cls):
        layerSetUp(cls)

    @classmethod
    def tearDown(cls):
        layerTearDown(cls)

    @classmethod
    def testSetUp(cls):
        layerTestSetUp(cls)

    @classmethod
    def testTearDown(cls):
        layerTestTearDown(cls)


class PylonsErrorLayer(object):

    config = 'errors.ini'

    @classmethod
    def setUp(cls):
        layerSetUp(cls)

    @classmethod
    def tearDown(cls):
        layerTearDown(cls)

    @classmethod
    def testSetUp(cls):
        layerTestSetUp(cls)

    @classmethod
    def testTearDown(cls):
        layerTestTearDown(cls)


class UtutiTestBrowser(NousTestBrowser):

    @classmethod
    def logIn(cls, email='admin@ututi.lt', password='asdasd'):
        browser = cls()
        form = browser.getForm('loginForm')
        form.getControl('Email').value = email
        form.getControl('Password').value = password
        form.getControl('Login').click()
        return browser


def setUp(test):
    test.globs['app'] = NousTestApp(pylons.test.pylonsapp)
    test.globs['Browser'] = UtutiTestBrowser


def tearDown(test):
    del test.globs['app']
    del test.globs['Browser']
