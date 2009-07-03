from zope.testing import doctest
from ututi.tests import PylonsLayer

from ututi.lib.image import serve_image


def test_serve_image():
    """

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
