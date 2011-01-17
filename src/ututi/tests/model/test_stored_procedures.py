import doctest
from ututi.tests import UtutiLayer

from sqlalchemy.sql.expression import select, literal_column
from sqlalchemy import func
from ututi.model import meta, User


def test_get_users():
    r"""An example of sqlalchemy code to get User objects out of a stored procedure.

    I expected this to work, but it does not:

        # >>> meta.Session.query(User).select_from(
        # ...     alias(func.get_users_by_email('admin@ututi.lt'), alias='users'))\
        # ...     .one().fullname
        # 'Adminas Adminovix'

    So if we will want to select some kind of object from a stored
    procedure, we will have to do it like this:


        >>> meta.Session.query(User)\
        ...     .from_statement(select([literal_column("*")]).select_from(func.get_users_by_email('admin@ututi.lt')))\
        ...     .first().fullname
        'Adminas Adminovix'

    Check that we got only one user:

        >>> list(meta.Session.query(User)\
        ...     .from_statement(select([literal_column("*")]).select_from(func.get_users_by_email('admin@ututi.lt'))))
        [<ututi.model.users.User object at ...>]

        >>> meta.Session.close()

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = UtutiLayer
    return suite
