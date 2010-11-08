from zope.testing import doctest
from ututi.tests import UtutiLayer

def test_urlify():
    """Test the function urlify.


        >>> from ututi.lib import urlify

    Removing lowercase lithuanian chars:
        >>> urlify(u'\u0105\u010d\u0119\u0117\u012f\u0161\u0173\u016b\u017e')
        'aceeisuuz'

        >>> urlify(u'\u0431\u0435\u0437\u0430\u0431\u0440\u0430\u0437\u044f \u043a\u0430\u043a\u0430\u044f \u0442\u0430 - \u0447\u043c\u043e \u0448\u0442\u043e \u0432\u043e\u0442')
        'bezabrazya_kakaya_ta___chmo_shto_vot'

    What about punctuation?

        >>> urlify('abra, kadabra: - it works?')
        'abra__kadabra____it_works_'

    And we should be able to limit the length.
        >>> len(urlify('123456789123456789123456789', 10))
        10
    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = UtutiLayer
    return suite
