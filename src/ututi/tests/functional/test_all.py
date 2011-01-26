import unittest

import ututi.tests.functional.errors
import ututi.tests.functional.slow
import ututi.tests.functional.quick
from ututi.tests import UtutiErrorsLayer, UtutiQuickLayer
from ututi.tests.functional import collect_ftests

def test_suite():
    return unittest.TestSuite([collect_ftests(),
                               collect_ftests(package=ututi.tests.functional.errors,
                                              layer=UtutiErrorsLayer),
                               collect_ftests(package=ututi.tests.functional.quick,
                                              layer=UtutiQuickLayer,
                                              setUp=ututi.tests.functional.quick.setUp,
                                              tearDown=ututi.tests.functional.quick.tearDown),
                               collect_ftests(package=ututi.tests.functional.slow,
                                              level=2)])
