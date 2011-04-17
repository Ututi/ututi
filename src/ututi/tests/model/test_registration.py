import doctest

from ututi.model import meta, LocationTag

from ututi.tests import UtutiLayer

import ututi

def test_init():
    """Tests that registration object always has a hash field filled:

        >>> from ututi.model.users import UserRegistration

    Let's create registration object:

        >>> registration = UserRegistration(LocationTag.get('uni'), 'user@example.com')

    Registration hash is filled:

        >>> registration.hash is not None
        True

    When added to session and committed, registration also gets an id:

        >>> meta.Session.add(registration)
        >>> meta.Session.flush()
        >>> registration.id
        1L

    """

def test_create_user():
    """Tests if all registration data is moved to the user created.

        >>> from ututi.model.users import UserRegistration

    Let's create registration object and fill it with data:

        >>> registration = UserRegistration(LocationTag.get('uni'), 'user@example.com')
        >>> registration.update_password('password')
        >>> registration.fullname = u'Mr User'
        >>> registration.openid = 'some googlish url'
        >>> registration.openid_email = 'user@gmail.com'
        >>> registration.facebook_id = 31337
        >>> registration.facebook_email = 'user@facebook.com'

    Now we create user and test if all data was transfered:

        >>> user = registration.create_user()
        >>> user.fullname
        u'Mr User'

        >>> user.username
        'user@example.com'

        >>> user.location.title
        u'U-niversity'

        >>> sorted([e.email for e in user.emails])
        ['user@example.com', 'user@facebook.com', 'user@gmail.com']

        >>> user.password == registration.password
        True

        >>> user.openid
        'some googlish url'

        >>> user.facebook_id
        31337

    Had we registered user without openid, he would only have single email:

        >>> registration = UserRegistration(LocationTag.get('uni'), 'another@example.com')
        >>> user = registration.create_user()
        >>> [e.email for e in user.emails]
        ['another@example.com']

    """

def _test_create_university():
    """Tests if all registration data is moved to the university created.

        >>> from ututi.model.users import UserRegistration
        >>> from ututi.model.i18n import Country

    Let's create registration object with empty location and fill in
    university data:

        >>> registration = UserRegistration(email='user@example.com')
        >>> registration.university_title = 'Vilnius University'
        >>> registration.university_country = Country.get_by_name('Lithuania')
        >>> registration.university_site_url = 'http://www.vu.lt'
        >>> registration.university_member_policy = 'RESTRICT_EMAIL'
        >>> registration.university_allowed_domains = 'vu.lt,mif.vu.lt,stud.mif.vu.lt'

    Adding logo is just a little bit more tricky:

        >>> from PIL import Image
        >>> from StringIO import StringIO
        >>> buffer = StringIO()
        >>> image = Image.new("RGB", (123, 123))
        >>> image.save(buffer, "PNG")
        >>> registration.university_logo = buffer.getvalue()

    When university is created, all data should be transfered:

        >>> university = registration._create_university()
        >>> university.parent is None
        True

        >>> university.title
        'Vilnius University'

        >>> university.title_short
        'vu.lt'

        >>> image = Image.open(StringIO(university.logo))
        >>> image.size
        (123, 123)

        >>> image.mode
        'RGB'

        >>> university.site_url
        'http://www.vu.lt'

        >>> university.member_policy
        'RESTRICT_EMAIL'

        >>> sorted([d.domain_name for d in university.email_domains])
        ['mif.vu.lt', 'stud.mif.vu.lt', 'vu.lt']

        >>> university.country.name
        'Lithuania'

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
    uni = LocationTag(u'U-niversity', u'uni', u'', member_policy='PUBLIC')
    meta.Session.add(uni)
    meta.Session.commit()
