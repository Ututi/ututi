import re
import doctest

from ututi.tests import UtutiLayer
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


def test_email_with_replies():
    r"""Tests for email_with_replies.

    `email_with_replies` marks reply text in emails.

        >>> from ututi.lib.helpers import email_with_replies
        >>> from ututi.lib.helpers import EXPAND_QUOTED_TEXT_LINK

        >>> email_with_replies('')
        literal(u'<br />')

    HTML escaping is automatically applied and newlines are replaced with <br>:

        >>> email_with_replies('<foo>\n</bar>')
        literal(u'&lt;foo&gt;<br />&lt;/bar&gt;<br />')

    Let's define a test helper function that will make the HTML easier on the
    eyes:

        >>> def test(s):
        ...     print ('\n'.join(email_with_replies(s.strip()).split('<br />'))
        ...            .replace(EXPAND_QUOTED_TEXT_LINK, '[...]<div>'))

    Consecutive newlines are removed:

        >>> test('\n\n1\n2\n\n\n\n3')
        1
        2
        <BLANKLINE>
        3
        <BLANKLINE>

    (In quotes too:)

        >>> test('''
        ... Hello
        ... >
        ... >
        ... >
        ... > Hi!
        ... ''')
        Hello [...]<div>
        &gt;
        &gt; Hi!</div>
        <BLANKLINE>

    '>' quotes are marked:

        >>> test('''
        ... Hi!
        ... > Hello!
        ... ''')
        Hi! [...]<div>
        &gt; Hello!</div>
        <BLANKLINE>

    Block quotes are grouped:

        >>> test('''
        ... Hi!
        ... > Hello!
        ... > 42
        ... > blue
        ... ''')
        Hi! [...]<div>
        &gt; Hello!
        &gt; 42
        &gt; blue</div>
        <BLANKLINE>

    Block quote headers are recognized:

        >>> test('''
        ... Hi!
        ...
        ... 2010/04/03 Mr. Foo <foo@example.com> wrote:
        ... > Hello!
        ... > 42
        ... > blue
        ... ''')
        Hi!
        <BLANKLINE>
        2010/04/03 Mr. Foo &lt;foo@example.com&gt; wrote: [...]<div>
        &gt; Hello!
        &gt; 42
        &gt; blue</div>
        <BLANKLINE>

    If there's an extra row between the reply and the header, it is removed.

        >>> test('''
        ... Hi!
        ...
        ... 2010/04/03 Mr. Foo <foo@example.com> wrote:
        ...
        ... > Hello!
        ... > 42
        ... > blue
        ... ''')
        Hi!
        <BLANKLINE>
        2010/04/03 Mr. Foo &lt;foo@example.com&gt; wrote: [...]<div>
        &gt; Hello!
        &gt; 42
        &gt; blue</div>
        <BLANKLINE>

    Corner cases:

        >>> test('>')
        [...]<div>
        &gt;</div>
        <BLANKLINE>

        >>> test('foo\n>\nbar')
        foo [...]<div>
        &gt;</div>
        <BLANKLINE>
        bar
        <BLANKLINE>

    """


def test_file_size():
    """

        >>> from ututi.lib.helpers import file_size

        >>> file_size(0)
        '0 B'
        >>> file_size(1)
        '1 B'

        >>> file_size(1023)
        '1023 B'
        >>> file_size(1024)
        '1 kB'
        >>> file_size(1025)
        '1.0 kB'

        >>> file_size(2047)
        '2.0 kB'
        >>> file_size(2048)
        '2 kB'
        >>> file_size(2049)
        '2.0 kB'

        >>> file_size(2**20-1)
        '1024.0 kB'
        >>> file_size(2**20)
        '1 MB'
        >>> file_size(2**20+1)
        '1.0 MB'

        >>> file_size(3 * 2**20 - 1)
        '3.0 MB'
        >>> file_size(3 * 2**20)
        '3 MB'
        >>> file_size(3 * 2**20 + 1)
        '3.0 MB'

    """


def test_wall_fmt():
    """Tests for wall text formatter.

        >>> from ututi.lib.helpers import wall_fmt

    The helper returns a literal string, because it may contain tags:

        >>> wall_fmt('Hello')
        literal(u'Hello')

    Wall text formatter is responsible for several things:
    1. escaping HTML entities

        >>> print wall_fmt('<b>Hello again</b>')
        &lt;b&gt;Hello again&lt;/b&gt;

    2. replacing newlines with <br /> tags

        >>> wall_fmt('Hello\\nagain')
        literal(u'Hello\\n<br/>\\nagain')

    3. activating links (and also emails)

        >>> print wall_fmt('Go to http://www.ututi.com.')
        Go to <a href="http://www.ututi.com">http://www.ututi.com</a>.

        >>> print wall_fmt('Go to www.ututi.com.')
        Go to <a href="http://www.ututi.com">www.ututi.com</a>.

        >>> print wall_fmt('Go to http://ututi.com.')
        Go to <a href="http://ututi.com">http://ututi.com</a>.

        >>> print wall_fmt('Contact us info@ututi.com.')
        Contact us <a href="mailto:info@ututi.com">info@ututi.com</a>.

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = UtutiLayer
    return suite

