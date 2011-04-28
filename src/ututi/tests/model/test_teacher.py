from datetime import date

import doctest

from ututi.model.users import User
from ututi.model import LocationTag
from ututi.model import Group
from ututi.model import meta

from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser

import ututi

def test_create_teacher():
    r"""Test creation of the teacher type.

       >>> from ututi.model.users import Teacher
       >>> teacher = Teacher(fullname=u'Petras', username='petras', location=LocationTag.get('uni'), password='qwerty', gen_password=True)
       >>> meta.Session.add(teacher)
       >>> meta.Session.commit()
       >>> meta.Session.flush()
       >>> teacher.teacher_verified
       False
       >>> teacher.type
       'teacher'

Just checking if he has emails (which come from the user):
       >>> len(teacher.emails)
       0

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
       >>> from ututi.model import Subject
       >>> teacher = Teacher(fullname=u'Petras', username='petras', location=LocationTag.get('uni'), password='qwerty', gen_password=True)
       >>> meta.Session.add(teacher)
       >>> meta.Session.commit()

       >>> teacher.taught_subjects
       []

       >>> res = meta.set_active_user(1)
       >>> s = Subject('subject_id', u'Subject title', LocationTag.get([u'vu']))
       >>> meta.Session.add(s)
       >>> teacher.taught_subjects.append(s)
       >>> meta.Session.commit()

       >>> teacher.taught_subjects
       [<ututi.model.Subject object at ...>]

       >>> s.teachers
       [<ututi.model.users.Teacher object at ...>]
    """

def test_teacher_groups():
    r"""Test linking teachers to student groups:

       >>> from ututi.model.users import Teacher, TeacherGroup
       >>> from ututi.model import Subject
       >>> teacher = Teacher(fullname=u'Petras', username='petras', location=LocationTag.get('uni'), password='qwerty', gen_password=True)
       >>> meta.Session.add(teacher)
       >>> meta.Session.commit()

       >>> teacher.groups
       []

Let's add a yahoo group:
       >>> res = meta.set_active_user(1)
       >>> tg = TeacherGroup(u'Some yahooers', u'group@groups.yahoo.com')
       >>> teacher.student_groups.append(tg)
       >>> meta.Session.commit()
       >>> res = meta.set_active_user(1)
       >>> teacher.student_groups
       [<ututi.model.users.TeacherGroup object at ...>]


Let's add a ututi group:
       >>> res = meta.set_active_user(1)
       >>> tg = TeacherGroup(u'Some Ututi users', 'moderators@groups.ututi.lt')
       >>> teacher.student_groups.append(tg)
       >>> meta.Session.commit()
       >>> res = meta.set_active_user(1)
       >>> teacher.student_groups
       [<ututi.model.users.TeacherGroup object at ...>,
        <ututi.model.users.TeacherGroup object at ...>]

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
    setUpUser()
    meta.set_active_user(1)
    g = Group('moderators', u'Moderators', LocationTag.get(u'uni'), date.today(), u'Moderators')
    meta.Session.add(g)
    meta.Session.commit()
    meta.set_active_user(1)
