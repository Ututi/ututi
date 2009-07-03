from zope.testing import doctest

from ututi.tests import PylonsLayer
from ututi.lib.helpers import ellipsis


def test_ellipsis():
    """Tests for ellipsis function.

    Ellipsis is a helper that shortens the text that is too long to
    fit into the designated space and adds 3 dots in the end. By
    default ellipsis allows up to 20 characters of text, so if we will
    pass a shorter string, nothing will happen:

        >>> ellipsis("Hello")
        'Hello'

    Though if the string is longer, it will get shortened:

        >>> ellipsis("01234567890123456789Hello")
        '01234567890123456...'

    We can pass the length of the string we need to the function
    though:

        >>> ellipsis("Hello", 4)
        'H...'

    As you can see, we are passing the length of the full string,
    ellipsis included.

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite

