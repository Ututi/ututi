"""
:doctest:
:unittest:

"""
from ututi.tests import *

class TestHelloController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='hello', action='index'))
        self.assertEqual(response.body, '')


def doctest_foo():
    """

       >>> print "lalala"
       lalala

       >>> import pylons.test
       >>> app = pylons.test.pylonsapp
       >>> response = app.get(url(controller='hello', action='index'))
       >>> response.body

    """

import z3c.testsetup
test_suite = z3c.testsetup.register_all_tests(
    'ututi.tests.functional')
