from zope.testing import doctest
from ututi.tests import PylonsLayer

from ututi.model import meta, Subject, Page, Group, LocationTag, SimpleTag, User
from ututi.lib.search import search


def _query_filter(query):
    """A simple callback that limits the query to one result"""
    return query.limit(1)


def test_basic_search():
    r"""Tests basic searching by text contents.

    A basic test: we set up a group and search for its text.
    Set the indexing language first, something the controllers always do for us.

        >>> u = User.get(u'admin@ututi.lt')
        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)

        >>> g = Group('new_group', u'Bioinformatikai', description=u'Grup\u0117 kurioje domimasi biologija ir informatika')
        >>> meta.Session.add(g)
        >>> meta.Session.commit()
        >>> results = search(u'biologija')
        >>> [result.object.title for result in results]
        [u'Bioinformatikai']

    Let's try out the lithuanian spelling:

        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)

        >>> [result.object.title for result in search(u'informatikos')]
        [u'Bioinformatikai']

    Let's add a subject and see what we get:

        >>> s = Subject('biologija', u'Biologijos pagrindai', LocationTag.get(u'vu'))
        >>> meta.Session.add(s)
        >>> [result.object.title for result in search(u'biologija')]
        [u'Bioinformatikai', u'Biologijos pagrindai']

    Let's try out the external query callback support:

        >>> [result.object.title for result in search(u'biologija', extra=_query_filter)]
        [u'Bioinformatikai']

    Let's filter by type:
        >>> [result.object.title for result in search(u'biologija', type='group')]
        [u'Bioinformatikai']

    No pages have been added yet:
        >>> [result.object.title for result in search(u'biologija', type='page')]
        []

    """


def test_tag_search():
    r"""Tests searching with tags.

    First, let's create a few items that we can search for.

        >>> u = User.get(u'admin@ututi.lt')
        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)

        >>> g = Group('new_grp', u'Biology students', description=u'biologija matematika infortikos mokslas')
        >>> g.location = LocationTag.get(u'vu/ef')
        >>> meta.Session.add(g)
        >>> tg = SimpleTag(u'test tag')
        >>> g.tags.append(tg)
        >>> meta.Session.commit()

    Now let's try searching for them by tags only

        >>> [result.object.title for result in search(tags=[u'test tag'])]
        [u'Biology students']

    We can combine location and simple tags

        >>> [result.object.title for result in search(tags=[u'test tag', u'vu'])]
        [u'Biology students']

    Let's add another tag and try searching for it. Nothing has been tagged with it, so we should
    get an empty list.

        >>> tg = SimpleTag(u'empty tag')
        >>> meta.Session.add(tg)
        >>> meta.Session.commit()
        >>> [result.object.title for result in search(tags=[u'test tag', u'empty tag'])]
        []

        >>> [result.object.title for result in search(tags=[u'test tag', u'empty new tag'])]
        []

    What about pages? They inherit their tags from the subjects they belong to. Let's see if they show up in
    search results.

        >>> s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'VU'))
        >>> t = SimpleTag(u'a tag')
        >>> meta.Session.add(t)
        >>> s.tags.append(t)
        >>> meta.Session.add(s)
        >>> u = User.get(u'admin@ututi.lt')
        >>> p = Page(u'page title', u'Puslapio tekstas', u)
        >>> meta.Session.add(p)
        >>> s.pages.append(p)
        >>> meta.Session.commit()

        >>> [result.object.title for result in search(tags=[u'a tag'])]
        [u'Test subject', u'page title']

        >>> [result.object.title for result in search(text=u'puslapis', tags=[u'a tag'])]
        [u'page title']
    """


def test_location_search():
    r"""Testing filtering by location.

    First let's create a few content items.

        >>> u = User.get(u'admin@ututi.lt')
        >>> res = meta.Session.execute("SET ututi.active_user TO %d" % u.id)

        >>> g = Group('new_group', u'Bioinformatikai', description=u'Grup\u0117 kurioje domimasi biologija ir informatika')
        >>> g.location = LocationTag.get(u'vu/ef')
        >>> s = Subject('biologija', u'Biologijos pagrindai', LocationTag.get(u'vu'))
        >>> p = Page(u'page title', u'Puslapio tekstas', u)
        >>> s.pages.append(p)
        >>> meta.Session.add(g)
        >>> meta.Session.add(s)
        >>> meta.Session.add(p)
        >>> meta.Session.commit()
        >>> sorted([result.object.title for result in search(tags=[u'vu'])])
        [u'Bioinformatikai', u'Biologijos pagrindai', u'page title']

        >>> [result.object.title for result in search(tags=[u'ef'])]
        [u'Bioinformatikai']

    """


def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE)
    suite.layer = PylonsLayer
    return suite
