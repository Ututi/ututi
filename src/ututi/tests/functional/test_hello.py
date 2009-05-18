"""
:doctest:
:unittest:

"""
import z3c.testsetup


def doctest_foo():
    """
       :layer: ututi.tests.PylonsLayer
       :setup: ututi.tests.setUp
       :teardown: ututi.tests.tearDown

       >>> from ututi.tests import url
       >>> print "lalala"
       lalala

       >>> response = app.get(url(controller='hello', action='index'))
       >>> print response.body
       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
       <html>
         <head>
          <title>OMG it works!</title>
         </head>
         <body>
       <h1>Hello</h1>
       <p>Lorum ipsum dolor yadda yadda</p>
         </body>
       </html>

    """


def doctest_hello2():
    """
       :layer: ututi.tests.PylonsLayer
       :setup: ututi.tests.setUp
       :teardown: ututi.tests.tearDown

       >>> from ututi.tests import url
       >>> response = app.get(url(controller='hello', action='index2'))
       >>> print response.body
       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
       <html>
         <head>
          <title></title>
         </head>
         <body>
       <h1>Hello</h1>
         </body>
       </html>

    """


test_suite = z3c.testsetup.register_doctests(
    'ututi.tests.functional')

# import ututi
# import doctest

# def test_suite():
#     optionflags = doctest.NORMALIZE_WHITESPACE | doctest.ELLIPSIS
#     suite = doctest.DocTestSuite(optionflags=optionflags,
#                                  setUp=ututi.tests.setUp,
#                                  tearDown=ututi.tests.tearDown)
#     suite.layer = ututi.tests.PylonsLayer
#     return suite
