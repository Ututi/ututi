#
import os
import unittest
from pkg_resources import resource_string, resource_stream

from zope.testing import doctest

from pylons import config

from nous.mailpost import processEmailAndPost

import ututi


def collect_ftests(package=None, level=None, layer=None, filenames=None,
                   exclude=None):
    """Collect all functional doctest files in a given package.

    If `package` is None, looks up the call stack for the right module.

    Returns a unittest.TestSuite.
    """
    package = doctest._normalize_module(package)
    testdir = os.path.dirname(package.__file__)
    if filenames is None:
        filenames = [fn for fn in os.listdir(testdir)
                     if fn.endswith('.txt') and not fn.startswith('.')]
    if exclude is not None:
        for fn in exclude:
            filenames.remove(fn)
    optionflags = (doctest.ELLIPSIS | doctest.REPORT_NDIFF |
                   doctest.NORMALIZE_WHITESPACE |
                   doctest.REPORT_ONLY_FIRST_FAILURE)
    suites = []
    for filename in filenames:
        suite = doctest.DocFileSuite(filename,
                                     package=package,
                                     optionflags=optionflags,
                                     setUp=ututi.tests.setUp,
                                     tearDown=ututi.tests.tearDown)
        suite.layer = ututi.tests.PylonsLayer
        if level is not None:
            suite.level = level
        suites.append(suite)
    return unittest.TestSuite(suites)


def listUploads(files_path=None):
    if files_path is None:
        files_path = config['files_path']
    for dir_name, subdirs, files in os.walk(files_path):
        if files:
            for file_name in files:
                full_name = os.path.join(dir_name, file_name)
                print full_name.replace(files_path, "/uploads")


def send_test_message(email_file, message_id, to, reply_to=None):
    message = resource_string("ututi.tests.functional.emails", email_file)
    if reply_to is not None:
        reply_to = "\nIn-Reply-To: <%s>" % reply_to
    else:
        reply_to = ''
    processEmailAndPost('http://localhost/got_mail',
                        message % {'message_id': message_id,
                                   'to': to,
                                   'reply_to': reply_to},
                        config['files_path'])


def make_file(filename):
    stream = resource_stream("ututi.tests.functional.import", filename)
    return (stream, 'text/plain', filename)


def import_csv(browser, formname, filename):
    browser.open('http://localhost/admin')
    form = browser.getForm(name=formname)
    form.getControl('CSV File').add_file(*make_file(filename))
    form.getControl('Upload').click()
