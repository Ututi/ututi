from zope.testing import doctest

from ututi.model import Email
from ututi.model import generate_salt
from ututi.model import generate_password
from ututi.model import validate_password
from ututi.model import User, meta
from ututi.tests import PylonsLayer


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

        >>> petras = User('Petras', 'qwerty', gen_password=True)
        >>> jonas = User('Jonas', '7jN1UP/WkmnVv/XZb28pFYf9flmlcIxUcoa1', gen_password=False)

        >>> meta.Session.add(petras)
        >>> meta.Session.add(jonas)

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

         >>> meta.Session.flush()
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
        'Adminas Adminovix'

    If we pass an email that does not exist, we should get None:

        >>> User.get('admin@ututi.com') is None
        True

    Let's see if it still works when we have more than one user in our
    database:

        >>> petras = User('Petras', 'asdasd', gen_password=True)
        >>> meta.Session.add(petras)
        >>> meta.Session.commit()

        >>> User.get('admin@ututi.lt') is admin
        True

    Hmm, what happens if 2 users have the same email, but one of them
    has not confirmed it yet:

        >>> email = Email("admin@ututi.lt")
        >>> meta.Session.add(email)
        >>> petras.email = email
        >>> meta.Session.commit()
        Traceback (most recent call last):
        ...
        FlushError: New instance <Email at ...> with
           identity key (<class 'ututi.model.Email'>, ('admin@ututi.lt',))
           conflicts with persistent instance <Email at ...>

    Well - it fails, and it should get fixed XXX

    We also have a function that gets users by their unique ids:

        >>> meta.Session.rollback()
        >>> User.get_byid(1) is admin
        True
        >>> User.get_byid(2) is petras
        True

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
