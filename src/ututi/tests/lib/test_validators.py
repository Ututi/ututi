from zope.testing import doctest
from ututi.tests import PylonsLayer

def test_html_cleanup():
    """Tests the html cleanup code.

    The cleanup should remove script tags.

        >>> from ututi.lib.validators import html_cleanup
        >>> input = '<script lang="javascript">a = 54;</script> <span onclick="a=54;">Normal text</span>'
        >>> html_cleanup(input)
        '<span>Normal text</span>'

    HTML comments are also removed.
        >>> input = '<!-- this is a comment --> aaaa'
        >>> html_cleanup(input)
        ' aaaa'

    CSS attributes are removed.
        >>> input = '<span style="color: black;">Text</span>'
        >>> html_cleanup(input)
        '<span>Text</span>'

    At the moment the only tags allowed are: a, img, span and div.
        >>> input = '<a>Text</a><img href="a.img"/><span>Text</span><div>Text</div>'
        >>> html_cleanup(input)
        '<a>Text</a><img href="a.img"><span>Text</span><div>Text</div>'

    and nothing else

        >>> input = '<a>Text</a><img href="a.img"/><span>Text</span><div>Text</div><blink>Blinking text</blink>'
        >>> html_cleanup(input)
        '<a>Text</a><img href="a.img"><span>Text</span><div>Text</div>Blinking text'

    not even html structure tags.
        >>> input = '<html><body><a>Text</a><img href="a.img"/><span>Text</span><div>Text</div></body></html>'
        >>> html_cleanup(input)
        '<a>Text</a><img href="a.img"><span>Text</span><div>Text</div>'


    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
