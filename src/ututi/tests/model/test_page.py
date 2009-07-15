from zope.testing import doctest

from ututi.model import Subject
from ututi.model import Page, PageVersion, Group, User, meta
from ututi.tests import PylonsLayer


def test_pages():
    """Test if pages are created and retrieved correctly.

    Pages are created by passing the title of the page, the content
    and the author to it's constructor:

        >>> admin = User.get('admin@ututi.lt')
        >>> page = Page(u'Some coursework', u'Some information about it.', admin)
        >>> meta.Session.add(page)
        >>> meta.Session.commit()

    When added to the database they get ids assigned automatically:

        >>> page.id
        1L

    Once created, a page can be retrieved by its id.

        >>> page = Page.get(page.id)

        >>> page.title
        u'Some coursework'

        >>> page.content
        u'Some information about it.'

        >>> page.author is admin
        True

    Also, the page is not storing the content directly. The moment you
    create it, a PageVersion object is created and assigned to the
    page:

        >>> page.versions
        [<ututi.model.PageVersion object at ...>]

    That version object stores the actual content:

         >>> page.versions[0].title
         u'Some coursework'

         >>> page.versions[0].content
         u'Some information about it.'

    A new version can be appended to the version list of an existing
    page.

        >>> version = PageVersion(u'Some coursework (updated)',
        ...                       u'Some more information about it.',
        ...                       admin)
        >>> page.versions.append(version)
        >>> meta.Session.commit()
        >>> page.content
        u'Some more information about it.'

    If you want to modify the content of a page you can also use a
    shorthand method instead of creatin a new version object directly:

        >>> page.add_version(u'Some coursework (new)',
        ...                  u'Some exclusive information about it.',
        ...                  admin)
        >>> meta.Session.commit()

        >>> page.title
        u'Some coursework (new)'

        >>> page.content
        u'Some exclusive information about it.'


    The version object will be created automatically:

        >>> [(version.title, version.content) for version in page.versions]
        [(u'Some coursework (new)', u'Some exclusive information about it.'),
         (u'Some coursework (updated)', u'Some more information about it.'),
         (u'Some coursework', u'Some information about it.')]

    """


def test_group_pages():
    """Test if pages can be linked to groups.

    We get our group

        >>> group = Group.get('moderators')

    But initially it has no pages:

        >>> group.pages
        []

    We can easily add one though:

        >>> author = User.get('admin@ututi.lt')
        >>> group.pages.append(Page(u'page', u'some content', author))
        >>> meta.Session.commit()
        >>> meta.Session.expire_all()

    The page should appear in the pages list of this group now:

        >>> group = Group.get('moderators')
        >>> len(group.pages)
        1
        >>> group.pages[0].title
        u'page'

        >>> group.pages[0].content
        u'some content'

    """


def test_subject_pages():
    """Test if pages can be linked to subjects.

    We get our subject

        >>> subject = Subject.get('mat_analize')

    But initially it has no pages:

        >>> subject.pages
        []

    We can easily add one though:

        >>> author = User.get('admin@ututi.lt')
        >>> subject.pages.append(Page(u'page', u'some content', author))
        >>> meta.Session.commit()
        >>> meta.Session.expire_all()

    The page should appear in the pages list of this subject now:

        >>> subject = Subject.get('mat_analize')
        >>> len(subject.pages)
        1
        >>> subject.pages[0].title
        u'page'

        >>> subject.pages[0].content
        u'some content'

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
