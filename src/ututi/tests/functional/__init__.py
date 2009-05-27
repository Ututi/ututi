#
import os
import unittest

from zope.testing import doctest

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
