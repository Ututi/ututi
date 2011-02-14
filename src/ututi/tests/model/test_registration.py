import doctest

from ututi.model import meta, LocationTag
from ututi.model.users import UserRegistration

from ututi.tests import UtutiLayer

import ututi

def test_init():
    """Tests that registration object always has a hash field filled:

    Let's create registration object:

        >>> registration = UserRegistration('user@example.com', LocationTag.get('uni'))

    Registration hash is filled:

        >>> registration.hash is not None
        True

    When added to session and committed, registration also gets an id:

        >>> meta.Session.add(registration)
        >>> meta.Session.commit()
        >>> registration.id
        1L

    """

def test_create_user():
    """Tests if all registration data is moved to the user created.

    Let's create registration object and fill it with data:

        >>> registration = UserRegistration('user@example.com', LocationTag.get('uni'))
        >>> registration.update_password('password')
        >>> registration.fullname = u'Mr User'
        >>> registration.openid = 'some googlish url'
        >>> registration.openid_email = 'user@gmail.com'
        >>> registration.facebook_id = 31337

    Now we create user and test if all data was transfered:

        >>> user = registration.create_user()
        >>> user.fullname
        u'Mr User'

        >>> user.username
        'user@example.com'

        >>> user.location.title
        u'U-niversity'

        >>> [e.email for e in user.emails]
        ['user@example.com', 'user@gmail.com']

        >>> user.password == registration.password
        True

        >>> user.openid
        'some googlish url'

        >>> user.facebook_id
        31337

    Had we registered user without openid, he would only have single email:

        >>> registration = UserRegistration('another@example.com', LocationTag.get('uni'))
        >>> user = registration.create_user()
        >>> [e.email for e in user.emails]
        ['another@example.com']

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
    uni = LocationTag(u'U-niversity', u'uni', u'')
    meta.Session.add(uni)
    meta.Session.commit()
