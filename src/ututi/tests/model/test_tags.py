from zope.testing import doctest

from ututi.model import Page, Subject, SimpleTag, LocationTag, User
from ututi.model import meta

from ututi.tests import PylonsLayer

def test_page_tags():
    """Test that page tags are always kept up to date with subject tags.

    Create a subject, add a page to it.
        >>> s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'VU'))
        >>> meta.Session.add(s)
        >>> u = User.get(u'admin@ututi.lt')
        >>> p = Page(u'page title', u'Page text', u)
        >>> meta.Session.add(p)
        >>> s.pages.append(p)
        >>> meta.Session.commit()

        >>> t = SimpleTag(u'a tag')
        >>> meta.Session.add(t)
        >>> s.tags.append(t)
        >>> meta.Session.commit()
        >>> p = Page.get(p.id)
        >>> [tag.title for tag in p.tags]
        [u'a tag']

    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
