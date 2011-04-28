import doctest

from ututi.model import Page, Subject, SimpleTag, LocationTag, User
from ututi.model import meta

from ututi.tests import setUp
from ututi.tests import UtutiLayer
from ututi.tests.model import setUpUser


def test_page_tags():
    """Test that page tags are always kept up to date with subject tags.
    The update work is done by database triggers, so we are basically testing
    them here.

    Create a subject, add a page to it.

        >>> u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
        >>> res = meta.set_active_user(u.id)

        >>> s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'VU'))
        >>> t = SimpleTag(u'old tag')
        >>> meta.Session.add(t)
        >>> s.tags.append(t)
        >>> meta.Session.add(s)
        >>> u = User.get(u'admin@uni.ututi.com', LocationTag.get('uni'))
        >>> p = Page(u'page title', u'Page text')
        >>> meta.Session.add(p)
        >>> s.pages.append(p)
        >>> meta.Session.commit()

    Does the new page already have tags its subject had?

        >>> p = Page.get(p.id)
        >>> [tag.title for tag in p.tags]
        [u'old tag']

    Let's add a new tag to the subject and see if the page reacts:

        >>> t = SimpleTag(u'a tag')
        >>> meta.Session.add(t)
        >>> s.tags.append(t)
        >>> meta.Session.commit()
        >>> p = Page.get(p.id)
        >>> [tag.title for tag in p.tags]
        [u'old tag', u'a tag']

    Let's try removing the tags from the subject:

        >>> s.tags = []
        >>> meta.Session.commit()
        >>> p = Page.get(p.id)
        >>> [tag.title for tag in p.tags]
        []

    """

def test_page_location():
    """Test the synchronization between page locations and the locations of the subjects
    the pages belong to.

        >>> u = User.get('admin@uni.ututi.com', LocationTag.get(u'uni'))
        >>> res = meta.set_active_user(u.id)

        >>> s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'uni'))
        >>> meta.Session.add(s)
        >>> p = Page(u'page title', u'Page text')
        >>> meta.Session.add(p)
        >>> s.pages.append(p)
        >>> meta.Session.commit()

    Does the new page already have tags its subject had?

        >>> res = meta.set_active_user(u.id)
        >>> p = Page.get(p.id)
        >>> p.location.title
        u'U-niversity'

    Let's change the subject's location and see what the page does:

        >>> s.location = LocationTag.get(u'uni/dep')
        >>> meta.Session.commit()
        >>> p = Page.get(p.id)
        >>> p.location.title
        u'D-epartment'

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup)
    suite.layer = UtutiLayer
    return suite

def test_setup(test):
    setUp(test)
    setUpUser()

    uni = LocationTag.get(u'uni')
    dep = LocationTag(u'D-epartment', u'dep', u'', uni, member_policy='PUBLIC')
    meta.Session.add(dep)
    meta.Session.commit()
