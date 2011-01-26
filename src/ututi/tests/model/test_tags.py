import doctest

from ututi.model import Page, Subject, SimpleTag, LocationTag, User
from ututi.model import meta

from ututi.tests import setUp
from ututi.tests import UtutiLayer


def test_page_tags():
    """Test that page tags are always kept up to date with subject tags.
    The update work is done by database triggers, so we are basically testing
    them here.

    Create a subject, add a page to it.

        >>> u = User.get('admin@ututi.lt')
        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)

        >>> s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'VU'))
        >>> t = SimpleTag(u'old tag')
        >>> meta.Session.add(t)
        >>> s.tags.append(t)
        >>> meta.Session.add(s)
        >>> u = User.get(u'admin@ututi.lt')
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

        >>> u = User.get('admin@ututi.lt')
        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)

        >>> s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'VU'))
        >>> meta.Session.add(s)
        >>> p = Page(u'page title', u'Page text')
        >>> meta.Session.add(p)
        >>> s.pages.append(p)
        >>> meta.Session.commit()

    Does the new page already have tags its subject had?

        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)
        >>> p = Page.get(p.id)
        >>> p.location.title
        u'Vilniaus universitetas'

    Let's change the subject's location and see what the page does:

        >>> s.location = LocationTag.get(u'vu/ef')
        >>> meta.Session.commit()
        >>> p = Page.get(p.id)
        >>> p.location.title
        u'Ekonomikos fakultetas'

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=setUp)
    suite.layer = UtutiLayer
    return suite
