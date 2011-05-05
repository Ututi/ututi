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

def test_create_update():
    """Tests that registration objects are not created for same
    (user, university) twice:

        >>> from ututi.model.users import UserRegistration as R

    We have no pending registrations, so create_or_update call will create
    new registration:

        >>> a = R.create_or_update(LocationTag.get('uni'), 'user@example.com')
        >>> meta.Session.flush()
        >>> print a.location.title_short
        uni

    Calling "create_or_update" with same parameters will retrieve the same
    registration object:

        >>> b = R.create_or_update(LocationTag.get('uni'), 'user@example.com')
        >>> meta.Session.flush()
        >>> a.id == b.id
        True

    Calling "create_or_update" with location uni/dep will update registration,
    but not create new one:

        >>> b = R.create_or_update(LocationTag.get('uni/dep'), 'user@example.com')
        >>> meta.Session.flush()
        >>> a.id == b.id
        True
        >>> print b.location.title_short
        dep

    This works the other way around as well:

        >>> b = R.create_or_update(LocationTag.get('uni'), 'user@example.com')
        >>> meta.Session.flush()
        >>> a.id == b.id
        True
        >>> print b.location.title_short
        uni

    However new registration would be created for different university:

        >>> c = R.create_or_update(LocationTag.get('frd'), 'user@example.com')
        >>> meta.Session.flush()
        >>> a.id == c.id
        False

    Also, if registration is created with no location:

        >>> d = R.create_or_update(None, 'user@example.com')
        >>> meta.Session.flush()
        >>> a.id == d.id, c.id == d.id
        (False, False)

        >>> e = R.create_or_update(None, 'user@example.com')
        >>> meta.Session.flush()
        >>> d.id == e.id
        True

    For another user, different registration objects are created:

        >>> a2 = R.create_or_update(LocationTag.get('uni/dep'), 'user2@example.com')
        >>> c2 = R.create_or_update(LocationTag.get('frd'), 'user2@example.com')
        >>> d2 = R.create_or_update(None, 'user2@example.com')
        >>> meta.Session.flush()
        >>> a.id == a2.id, c.id == c2.id, d == d2.id
        (False, False, False)

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
    uni = LocationTag(u'U-niversity', u'uni', member_policy='PUBLIC')
    dep = LocationTag(u'D-epartment', u'dep', member_policy='PUBLIC', parent=uni)
    frd = LocationTag(u'University of Freedom', u'frd', member_policy='PUBLIC')
    meta.Session.add(uni)
    meta.Session.add(dep)
    meta.Session.add(frd)
    meta.Session.commit()
