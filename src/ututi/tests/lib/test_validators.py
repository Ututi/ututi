from zope.testing import doctest
from ututi.tests import PylonsLayer

from ututi.lib.validators import html_cleanup


def test_html_cleanup():
    """Tests the html cleanup code.

    The cleanup should remove script tags.

        >>> input = '<script lang="javascript">a = 54;</script> <span onclick="a=54;">Normal text</span>'
        >>> html_cleanup(input)
        '<div><span>Normal text</span></div>'

    HTML comments are also removed.
        >>> input = '<!-- this is a comment --> aaaa'
        >>> html_cleanup(input)
        '<div> aaaa</div>'

    CSS attributes are removed.
        >>> input = '<span style="color: black;">Text</span>'
        >>> html_cleanup(input)
        '<div><span>Text</span></div>'

    At the moment the only tags allowed are: a, img, span and div.
        >>> input = '<a>Text</a><img href="a.img"/><span>Text</span><div>Text</div>'
        >>> html_cleanup(input)
        '<div><a>Text</a><img href="a.img"><span>Text</span><div>Text</div></div>'

    and nothing else

        >>> input = '<a>Text</a><img href="a.img"/><span>Text</span><div>Text</div><blink>Blinking text</blink>'
        >>> html_cleanup(input)
        '<div><a>Text</a><img href="a.img"><span>Text</span><div>Text</div>Blinking text</div>'

    not even html structure tags.
        >>> input = '<html><body><a>Text</a><img href="a.img"/><span>Text</span><div>Text</div></body></html>'
        >>> html_cleanup(input)
        '<div><a>Text</a><img href="a.img"><span>Text</span><div>Text</div></div>'


    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
