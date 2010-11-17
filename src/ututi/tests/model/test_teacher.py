from zope.testing import doctest

from ututi.model import meta

from ututi.tests import UtutiLayer
import ututi

def test_create_teacher():
    r"""Test creation of the teacher type.

       >>> from ututi.model.users import Teacher
       >>> teacher = Teacher(fullname=u'Petras', password='qwerty', gen_password=True)
       >>> meta.Session.add(teacher)
       >>> meta.Session.commit()
       >>> meta.Session.flush()
       >>> teacher.teacher_verified
       False
       >>> teacher.user_type
       'teacher'

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = UtutiLayer
    return suite


def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)
