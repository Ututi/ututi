import unittest

import ututi.tests.functional.errors
import ututi.tests.functional.slow
import ututi.tests.functional.quick
import ututi.tests.functional.almost_quick
from ututi.tests import UtutiErrorsLayer, UtutiQuickLayer, U2tiQuickLayer, UtutiFunctionalLayer, U2tiFunctionalLayer
from ututi.tests.functional import collect_ftests

def test_suite():
    return unittest.TestSuite([collect_ftests(layer=[UtutiQuickLayer, U2tiQuickLayer],
                                              tearDown=ututi.tests.functional.quick.tearDown,
                                              exclude=['news.txt']),
                               collect_ftests(package=ututi.tests.functional.almost_quick,
                                              layer=[UtutiFunctionalLayer, U2tiFunctionalLayer]),
                               collect_ftests(package=ututi.tests.functional.errors,
                                              tearDown=ututi.tests.functional.quick.tearDown,
                                              layer=UtutiErrorsLayer),
                               collect_ftests(package=ututi.tests.functional.quick,
                                              layer=[UtutiQuickLayer, U2tiQuickLayer],
                                              setUp=ututi.tests.functional.quick.setUp,
                                              tearDown=ututi.tests.functional.quick.tearDown),
                               collect_ftests(package=ututi.tests.functional.slow,
                                              layer=[UtutiFunctionalLayer, U2tiFunctionalLayer],
                                              level=2)])
