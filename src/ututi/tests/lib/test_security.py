# coding=utf-8

import doctest

from ututi.model import User, Subject, LocationTag, meta
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser

import ututi

from ututi.lib.security import is_department_student, is_university_student


def test_department_student():
    r"""

    >>> u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni/dept2'))
    >>> is_department_student(u, LocationTag.get(u'uni/dept1'))
    False
    >>> is_department_student(u, LocationTag.get(u'uni'))
    False
    >>> is_department_student(u, LocationTag.get(u'uni/dept2'))
    True
    >>> subject1 = Subject.get(LocationTag.get(u'uni/dept1'), u'subject1')
    >>> subject2 = Subject.get(LocationTag.get(u'uni/dept2'), u'subject2')
    >>> is_department_student(u, subject1)
    False
    >>> is_department_student(u, subject2)
    True

    """


def test_university_student():
    r"""

    >>> u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni/dept2'))
    >>> is_university_student(u, LocationTag.get(u'uni'))
    True
    >>> is_university_student(u, LocationTag.get(u'uni/dept1'))
    True
    >>> is_university_student(u, Subject.get(LocationTag.get(u'uni/dept1'), u'subject1'))
    True
    >>> is_university_student(u, LocationTag.get(u'other_uni'))
    False

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

    uni = LocationTag.get(u'uni')
    u = User.get('admin@uni.ututi.com', uni)
    meta.set_active_user(u.id)
    dept1 = LocationTag(title=u'dept1',
                        title_short=u'dept1',
                        parent=uni,
                        member_policy='PUBLIC')
    dept2 = LocationTag(title=u'dept2',
                        title_short=u'dept2',
                        parent=uni,
                        member_policy='PUBLIC')
    other_uni = LocationTag(title=u'other_uni',
                            title_short=u'other_uni',
                            parent=None,
                            member_policy='PUBLIC')
    meta.Session.add_all([dept1, dept2, other_uni])
    meta.Session.commit()

    meta.set_active_user(u.id)

    subj1 = Subject(u'subject1', u'Subject1', dept1, u'')
    subj2 = Subject(u'subject2', u'Subject2', dept2, u'')
    meta.Session.add_all([subj1, subj2])

    u = User.get('admin@uni.ututi.com', uni)
    u.location = LocationTag.get(u'uni/dept2')
    meta.Session.add(u)
    meta.Session.commit()

    meta.Session.commit()
    meta.set_active_user(u.id)
