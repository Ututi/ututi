# coding=utf-8

from zope.testing import doctest

from ututi.tests import PylonsLayer
from ututi.lib.latex import replace_latex_to_html


def test_replace_between_latex_and_html():
    r"""Tests for replace_latex_to_html and replace_html_to_latex functions.

    Replace latex annotated html text to fully html (latex parts are
    converted to image elements plus script elements to preserve the
    latex script)

        >>> latex = '<p>Jei $$\lim_{n \\to \infty} a_n &gt; 0$$, tai $$\sum_{n=1}^\infty a_n$$ diverguoja.</p>'
        >>> print replace_latex_to_html(latex)
        <p>Jei <img class="latex" alt="\lim_{n \to \infty} a_n &gt; 0"
                    src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;latex=%5Cdisplaystyle+%5Clim_%7Bn+%5Cto+%5Cinfty%7D+a_n+%3E+0" />,
        tai <img class="latex" alt="\sum_{n=1}^\infty a_n"
                 src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;latex=%5Cdisplaystyle+%5Csum_%7Bn%3D1%7D%5E%5Cinfty+a_n" />
        diverguoja.</p>

    When there is an error - somehow user used html formatting - we
    need to ignore that:

        >>> latex = '''
        ... <p>Jei $$\lim_{n \\to \infty} <strong>a_n &gt; 0$$, ta</strong>i
        ... $$\sum_{n=1}^\infty a_n$$ diverguoja.</p>
        ... '''
        >>> print replace_latex_to_html(latex)
        <p>Jei $$\lim_{n \to \infty} <strong>a_n &gt; 0$$, ta</strong>i
          <img class="latex" alt="\sum_{n=1}^\infty a_n"
               src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;latex=%5Cdisplaystyle+%5Csum_%7Bn%3D1%7D%5E%5Cinfty+a_n" />
        diverguoja.</p>

     We want to handle cases where one of the separators is missing
     properly too:

        >>> latex = '''
        ... <p>Jei $$\lim_{n \\to \infty} <strong>a_n &gt; 0, ta</strong>i
        ... $$\sum_{n=1}^\infty a_n$$ diverguoja.</p>
        ... '''
        >>> print replace_latex_to_html(latex)
        <p>Jei $$\lim_{n \to \infty} <strong>a_n &gt; 0, ta</strong>i
          <img class="latex" alt="\sum_{n=1}^\infty a_n"
               src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;latex=%5Cdisplaystyle+%5Csum_%7Bn%3D1%7D%5E%5Cinfty+a_n" />
        diverguoja.</p>

    Strings without any separators should stay the same:

        >>> print replace_latex_to_html('Hello!')
        Hello!

    Strings with utf8 characters should not fail (however current latex web
    service does not support them and so will display incorrectly):

        >>> replace_latex_to_html(u'\u0126ello, $$\u017eeme$$!')
        u'\u0126ello, <img class="latex" alt="\u017eeme" src="http://l.wordpress.com/latex.php?bg=ffffff&amp;fg=000000&amp;s=0&amp;latex=%5Cdisplaystyle+%C5%BEeme" />!'

    Emtpy strings should stay empty:

        >>> print replace_latex_to_html('')

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite

