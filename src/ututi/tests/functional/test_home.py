import ututi
import doctest


def doctest_index():
    """

       >>> response = app.get('/')
       >>> response.forms['loginForm']
       <webtest.Form object at ...>

    """


def test_suite():
    optionflags = doctest.NORMALIZE_WHITESPACE | doctest.ELLIPSIS
    suite = doctest.DocTestSuite(optionflags=optionflags,
                                 setUp=ututi.tests.setUp,
                                 tearDown=ututi.tests.tearDown)
    suite.layer = ututi.tests.PylonsLayer
    return suite
