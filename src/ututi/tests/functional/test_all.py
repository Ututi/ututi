import unittest

import ututi.tests.functional.errors
import ututi.tests.functional.slow
from ututi.tests import UtutiErrorsLayer
from ututi.tests.functional import collect_ftests

def test_suite():
    return unittest.TestSuite([collect_ftests(),
                               collect_ftests(package=ututi.tests.functional.errors,
                                              layer=UtutiErrorsLayer),
                               collect_ftests(package=ututi.tests.functional.slow,
                                              level=2)])
