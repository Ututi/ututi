"""
:doctest:
:unittest:

"""

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

import z3c.testsetup
test_suite = z3c.testsetup.register_all_tests(
    'ututi.tests.functional')
