from datetime import date

from zope.testing import doctest

from ututi.model import Group
from ututi.model import Subject, LocationTag, Email, User
from ututi.model import generate_salt, generate_password, validate_password
from ututi.model import meta

from ututi.model import GroupMembershipType, GroupMember

from ututi.tests import PylonsLayer
import ututi


def test_generate_salt():
    r"""Test for random salt generation for passwords.

    Generate salt generates strings of 7 random bytes:

        >>> generate_salt()
        '\r\x16h\x1b\xe6\t\x89'

    Every time you call this function a new salt is generated:

        >>> generate_salt()
        'U\xda(VU>\x00'

    Though the basic parameters of the generated string do not change:

        >>> for i in range(1000):
        ...     salt = generate_salt()
        ...     for char in salt:
        ...         assert 0 <= ord(char) < 256
        ...         assert len(salt) == 7

    """


def test_generate_validate_password():
    r"""Test for password hashing and validation functions.

    We hash our passwords before storing them, to do that we are using
    the same algorithm that plone does, so our users would not have to
    change their passwords after we migrate everything to the new
    system.

    Our passwords are stored as base64 encoded strings:

        >>> b64hash = generate_password('asdasd')
        >>> b64hash
        'Z9U27E/Dt46+iA/twVLEtTzbozwNFmgb5gmJ'

    The decoded string is composed of a binary sha hash of the
    password + 7 bytes of salt:

        >>> from binascii import a2b_base64
        >>> hash = a2b_base64(b64hash)
        >>> hash
        'g\xd56\xecO\xc3\xb7\x8e\xbe\x88\x0f\xed\xc1R\xc4\xb5<\xdb\xa3<\r\x16h\x1b\xe6\t\x89'

    So if we split the hash into two parts, and encode the password
    using the salt, we should get the same result:

         >>> import sha
         >>> pwd_hash, salt = hash[:-7], hash[-7:]
         >>> sha.new('asdasd' + salt).digest() == pwd_hash
         True

    But to make it easier to do we have all that code in our password
    validation function:

        >>> validate_password(b64hash, 'asdasd')
        True

    If we pass an invalid hash to the function, it will just return
    False:

        >>> validate_password('', 'asdasd')
        False

    And even if the hash is valid, a different password will not get
    through:

        >>> validate_password(b64hash, 'qwerty')
        False

    """


def test_User():
    """Tests for User constructor.

    Let's create a couple of users:

        >>> petras = User(u'Petras', 'qwerty', gen_password=True)
        >>> jonas = User(u'Jonas', '7jN1UP/WkmnVv/XZb28pFYf9flmlcIxUcoa1', gen_password=False)

        >>> meta.Session.add(petras)
        >>> meta.Session.flush()
        >>> meta.Session.add(jonas)
        >>> meta.Session.flush()

    The password for petras should have been encoded, as we don't want
    our administrators knowing the actual passwords our users are
    using:

        >>> petras.password
        'qYTGmExVUDmtBN/iiHWNeQU0ajYNFmgb5gmJ'

        >>> validate_password(petras.password, 'qwerty')
        True

    Though if we had the password hash passed directly it should work:

        >>> validate_password(jonas.password, 'asdasd')
        True

    Both users got assigned an id by the database:

         >>> petras.id, jonas.id
         (2L, 3L)

    """


def test_User_get():
    """Tests for user retrieval from the database.

    Most of our model classes have code that gets an instance of an
    object by it's unique id/key. The function is called `get' most of
    the time. As our clean database contains one user by default,
    let's try and get him:

        >>> admin = User.get('admin@ututi.lt')

        >>> admin
        <ututi.model.User object at ...>

        >>> admin.fullname
        u'Adminas Adminovix'

    If we pass an email that does not exist, we should get None:

        >>> User.get('admin@ututi.com') is None
        True

    Let's see if it still works when we have more than one user in our
    database:

        >>> petras = User(u'Petras', 'asdasd', gen_password=True)
        >>> meta.Session.add(petras)
        >>> meta.Session.commit()

        >>> User.get('admin@ututi.lt') is admin
        True
        >>> meta.Session.commit()
        >>> meta.Session.remove()

    Hmm, what happens if 2 users have the same email, but one of them
    has not confirmed it yet:

        >>> petras = User.get_byid(2)
        >>> petras.emails.append(Email("admin@ututi.lt"))

        >>> meta.Session.commit()
        Traceback (most recent call last):
        ...
        IntegrityError: (IntegrityError) duplicate key value violates unique constraint "emails_pkey"
          'INSERT INTO emails (id, email) VALUES (%(id)s, %(email)s)' {...}

    XXX Argh, we have no idea which of the two possible errors we will get.

    Well - it fails, and it should get fixed XXX

    We also have a function that gets users by their unique ids:

        >>> meta.Session.rollback()
        >>> User.get_byid(2) is petras
        True

    """


def test_user_subject_watching():
    r"""Test for user subject watching and unwatching.

        >>> user = User.get('admin@ututi.lt')
        >>> res = meta.Session.execute("SET ututi.active_user TO %s" % user.id)
        >>> location = LocationTag.get([u'vu', u'ef'])
        >>> subjects = []
        >>> for i in range(5):
        ...     subject = Subject('subject%d' % i, u'Subject %d' % i, location)
        ...     subjects.append(subject)
        ...     meta.Session.add(subject)
        >>> meta.Session.commit()
        >>> res = meta.Session.execute("SET ututi.active_user TO %s" % user.id)

    All the subjects added to it, are visible in the list:

        >>> user.watchSubject(subjects[0])
        >>> user.watchSubject(subjects[1])
        >>> sorted([s.title for s in user.watched_subjects])
        [u'Subject 0', u'Subject 1']

        >>> user.watchSubject(subjects[2])
        >>> sorted([s.title for s in user.watched_subjects])
        [u'Subject 0', u'Subject 1', u'Subject 2']

    Subjects watched by group our user is in are included in the list
    together with subjects watched by our user directly:

        >>> group = Group.get('moderators')
        >>> group.watched_subjects.append(subjects[3])
        >>> group.watched_subjects.append(subjects[4])

        >>> sorted([s.title for s in user.all_watched_subjects])
        [u'Subject 0', u'Subject 1', u'Subject 2', u'Subject 3', u'Subject 4']

    Even when group is watching same subjects that the user is, we
    should only see the subject once:

        >>> group.watched_subjects.append(subjects[2])
        >>> group.watched_subjects.append(subjects[0])

        >>> sorted([s.title for s in user.all_watched_subjects])
        [u'Subject 0', u'Subject 1', u'Subject 2', u'Subject 3', u'Subject 4']

    User can "unwatch" subjects, but that will only remove the subject
    from his watched subjects list:

        >>> user.unwatchSubject(subjects[2])

        >>> sorted([s.title for s in user.all_watched_subjects])
        [u'Subject 0', u'Subject 1', u'Subject 2', u'Subject 3', u'Subject 4']

        >>> sorted([s.title for s in user.watched_subjects])
        [u'Subject 0', u'Subject 1']

    On the other hand - user can ignore subjects:

        >>> user.ignoreSubject(subjects[0])

    The subject will stay in all watched subjects, because I am
    watching it directly.

        >>> sorted([s.title for s in user.all_watched_subjects])
        [u'Subject 0', u'Subject 1', u'Subject 2', u'Subject 3', u'Subject 4']

        >>> sorted([s.title for s in user.watched_subjects])
        [u'Subject 0', u'Subject 1']

    It will also be in the ignored_subjects list:

        >>> sorted([s.title for s in user.ignored_subjects])
        [u'Subject 0']

    And if I will stop watching it, it will disappear the
    all_watched_subjects list:

        >>> user.unwatchSubject(subjects[0])

        >>> sorted([s.title for s in user.all_watched_subjects])
        [u'Subject 1', u'Subject 2', u'Subject 3', u'Subject 4']

    Unless I stop ignoring it:

        >>> user.unignoreSubject(subjects[0])

        >>> sorted([s.title for s in user.all_watched_subjects])
        [u'Subject 0', u'Subject 1', u'Subject 2', u'Subject 3', u'Subject 4']

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = PylonsLayer
    return suite


def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)

    u = User.get('admin@ututi.lt')
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)

    g = Group('moderators', u'Moderatoriai', LocationTag.get(u'vu'), date.today(), u'U2ti moderatoriai.')
    role = GroupMembershipType.get('administrator')
    gm = GroupMember()
    gm.user = u
    gm.group = g
    gm.role = role
    meta.Session.add(g)
    meta.Session.add(gm)
    meta.Session.commit()
