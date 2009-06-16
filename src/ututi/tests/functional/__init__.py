#
import os
import unittest

from zope.testing import doctest

from pylons import config

import ututi


def collect_ftests(package=None, level=None, layer=None, filenames=None):
    """Collect all functional doctest files in a given package.

    If `package` is None, looks up the call stack for the right module.

    Returns a unittest.TestSuite.
    """
    package = doctest._normalize_module(package)
    testdir = os.path.dirname(package.__file__)
    if filenames is None:
        filenames = [fn for fn in os.listdir(testdir)
                     if fn.endswith('.txt') and not fn.startswith('.')]
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
