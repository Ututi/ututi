from zope.testing import doctest

from ututi.model import meta

from ututi.tests import UtutiLayer
import ututi

def test_create_teacher():
    r"""Test creation of the teacher type.

       >>> from ututi.model.users import Teacher, User
       >>> teacher = Teacher(fullname=u'Petras', password='qwerty', gen_password=True)
       >>> meta.Session.add(teacher)
       >>> meta.Session.commit()
       >>> meta.Session.flush()
       >>> teacher.teacher_verified
       False
       >>> teacher.user_type
       'teacher'

       >>> user = User.get_byid(teacher.id)
       >>> user
       <ututi.model.users.Teacher object at ...

When querying for teachers, only teacher objects should be returned:
       >>> [t for t in meta.Session.query(Teacher).all()]
       [<ututi.model.users.Teacher object ...

    """

def test_teacher_subjects():
    r"""Test linking teachers to the subjects they teach:

       >>> from ututi.model.users import Teacher
       >>> from ututi.model import Subject, LocationTag
       >>> teacher = Teacher(fullname=u'Petras', password='qwerty', gen_password=True)
       >>> meta.Session.add(teacher)
       >>> meta.Session.commit()

       >>> teacher.tought_subjects
       []

       >>> res = meta.Session.execute("SET ututi.active_user TO 1")
       >>> s = Subject('subject_id', u'Subject title', LocationTag.get([u'vu']))
       >>> meta.Session.add(s)
       >>> teacher.tought_subjects.append(s)
       >>> meta.Session.commit()

       >>> teacher.tought_subjects
       [<ututi.model.Subject object at ...>]
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
