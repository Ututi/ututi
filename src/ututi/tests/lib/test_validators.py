import doctest
from ututi.tests import UtutiLayer
from pylons import config

def test_html_cleanup():
    """Test the html cleanup code.

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


def test_phonenumbervalidator():
    """Test for PhoneNumberValidator.

        >>> from ututi.lib.validators import PhoneNumberValidator
        >>> v = PhoneNumberValidator()

        >>> print v.to_python('', {})
        None

    The widget validates Lithuanian phone numbers. It supports two formats,
    with the international prefix and without one:

        >>> v.to_python('+37069912345', {})
        '+37069912345'
        >>> v.to_python('869912345', {})
        '+37069912345'

    Extra characters are stripped away:

        >>> v.to_python('8-699-12345', {})
        '+37069912345'
        >>> v.to_python('8 (699) 12345', {})
        '+37069912345'

    Perhaps the validator is a bit too open about what it accepts?

        >>> v.to_python('foo8bar699xyzzy12345', {})
        '+37069912345'

    Length of the number is validated:

        >>> v.to_python('8 (699) 123456', {})
        Traceback (most recent call last):
            ...
        Invalid: Phone number too long; use the format +37069912345

        >>> v.to_python('8 (699) 1234', {})
        Traceback (most recent call last):
            ...
        Invalid: Phone number too short; use the format +37069912345

    + is not allowed in the middle of the string:

        >>> v.to_python('8+699+123', {})
        Traceback (most recent call last):
            ...
        Invalid: Invalid phone number; use the format +37069912345

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = UtutiLayer
    return suite
