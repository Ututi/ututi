from zope.testing import doctest

from ututi.model import Page, PageVersion, Group, User, meta
from ututi.tests import PylonsLayer

def test_pages():
    """Test if pages are created and retrieved correctly.

        >>> admin = User.get('admin@ututi.lt')
        >>> admin.id
        1L
        >>> page = Page('page1', admin)
        >>> meta.Session.add(page)
        >>> meta.Session.commit()
        >>> page.id
        1L

        Once created, a page can be retrieved by its id.

        >>> page_too = Page.get(page.id)
        >>> page_too.content
        'page1'

        A new version can be appended to an existing page.

        >>> new_version = PageVersion('page1, but newer', admin)
        >>> meta.Session.add(new_version)
        >>> page_too.versions.append(new_version)
        >>> meta.Session.commit()
        >>> page_too.content == new_version.content
        True

        A new version is created by simply modifying the content of a page.

        >>> page_too.add_version('totally new', admin)
        >>> meta.Session.commit()
        >>> page = Page.get(page_too.id)
        >>> page.content
        'totally  new'

        """

def test_group_pages():
    """Test if pages can be linked to groups.

    Let's create a page.
        >>> admin = User.get('admin@ututi.lt')
        >>> admin.id
        1L
        >>> page = Page('page', admin)
        >>> meta.Session.add(page)
        >>> meta.Session.commit()
        >>> page.id
        1L

        >>> grp = Group.get('moderators')
        >>> grp.id
        'moderators'

    The group has no pages.
        >>> grp.pages
        []


        >>> grp.pages.append(page)
        >>> meta.Session.commit()

        >>> grp = Group.get('moderators')
        >>> len(grp.pages)
        1
        >>> grp.pages[0].content
        'page'
    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
