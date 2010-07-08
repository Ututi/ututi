from datetime import date
from zope.testing import doctest

from pylons import config

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, User, meta
from ututi.model import meta, Subject, Page, SimpleTag, File

from ututi.tests import PylonsLayer
import ututi

from ututi.lib.search import search


def _query_filter(query):
    """A simple callback that limits the query to one result"""
    return query.limit(1)


def test_basic_search():
    r"""Tests basic searching by text contents.

    A basic test: we set up a group and search for its text.
    Set the indexing language first, something the controllers always do for us.

        >>> results = search(text=u'biologija')
        >>> [result.object.title for result in results]
        [u'Bioinformatikai', u'Biology students', u'Biologijos pagrindai']

    Let's try out the lithuanian spelling:

        >>> [result.object.title for result in search(text=u'informatikos')]
        [u'Bioinformatikai', u'Biology students']

    Let's search for a subject and see what we get:

        >>> [result.object.title for result in search(text=u'biologija', type='subject')]
        [u'Biologijos pagrindai']

    Let's try out the external query callback support:

        >>> [result.object.title for result in search(text=u'biologija', extra=_query_filter)]
        [u'Bioinformatikai']

    Let's filter by type:
        >>> [result.object.title for result in search(text=u'biologija', type='group')]
        [u'Bioinformatikai', u'Biology students']

    No pages have been added yet:
        >>> [result.object.title for result in search(text=u'biologija', type='page')]
        []

    Test file search:
        >>> results = search(text=u'geografija')
        >>> [result.object.title for result in results]
        [u'geografija']


    """


def test_tag_search():
    r"""Tests searching with tags.

    First, let's create a few items that we can search for.

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
        >>> res = meta.Session.execute("SET default_text_search_config TO 'public.lt'")

        >>> [result.object.title for result in search(tags=[u'test tag', u'empty tag'])]
        []

        >>> [result.object.title for result in search(tags=[u'test tag', u'empty new tag'])]
        []

    What about pages? They inherit their tags from the subjects they belong to. Let's see if they show up in
    search results.

        >>> sorted([result.object.title for result in search(tags=[u'a tag'])])
        [u'Test subject', u'page title']

        >>> [result.object.title for result in search(text=u'puslapis', tags=[u'a tag'])]
        [u'page title']

    Mixed tags are the tags that are matched by both location tags and simple tags.
        >>> sorted([(result.object.title, result.object.content_type) for result in search(tags=[u'Ekologijos fakultetas'])])
        [(u'Ekologai', 'group'), (u'Test subject', 'subject'), (u'page title', 'page')]

    Take a look at the rating just cause they are here:
        >>> [(result.rating, result.object.title) for result in search(text=u'pagrindai', type='subject')]
        [(2, u'Biologijos pagrindai'), (1, u'Test subject')]
    """


def test_location_search():
    r"""Testing filtering by location.

        >>> sorted([result.object.title for result in search(tags=[u'vu'])])
        [u'Biologijos pagrindai', u'Biology students', u'Test subject', u'geografija', u'page title', u'page title']

        >>> sorted([result.object.title for result in search(tags=[u'ef'])])
        [u'Biology students', u'Ekologai']

    Intersecting this tag with its parent tag should get us only the intersection.
        >>> sorted([result.object.title for result in search(tags=[u'vu', u'ef'])])
        [u'Biology students']

        >>> sorted([result.object.title for result in search(tags=[u'ef', u'ktu'])])
        [u'Ekologai']
    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup,
        tearDown=tear_down)
    suite.layer = PylonsLayer
    return suite


def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)

    u = User.get(u'admin@ututi.lt')
    from ututi.model import initialize_dictionaries
    initialize_dictionaries(meta.engine)
    meta.Session.execute("SET ututi.active_user TO %d" % u.id)
    meta.Session.execute("SET default_text_search_config TO 'public.lt'")

    l = LocationTag(u'Kauno technologijos universitetas', u'ktu', u'')
    f = LocationTag(u'Ekologijos fakultetas', u'ef', u'', l)

    mtag = SimpleTag(u'Ekologijos fakultetas') #a mixed tag

    meta.Session.add(l)
    meta.Session.add(f)

    g = Group('agroup', u'Ekologai', description=u'testas')
    g.location = f
    meta.Session.add(g)

    g = Group('new_group', u'Bioinformatikai', description=u'Grup\u0117 kurioje domimasi biologija ir informatika')
    meta.Session.add(g)

    # a tagged group
    g2 = Group('new_grp', u'Biology students', description=u'biologija matematika informatikos mokslas')
    g2.location = LocationTag.get(u'vu/ef')

    meta.Session.add(g2)
    tg = SimpleTag(u'test tag')
    g2.tags.append(tg)

    s = Subject(u'subj_id', u'Test subject', LocationTag.get(u'VU'))
    s.description = u'pagrindai'
    t = SimpleTag(u'a tag')
    meta.Session.add(t)
    s.tags.append(t)
    s.tags.append(mtag)
    meta.Session.add(s)
    p = Page(u'page title', u'Puslapio tekstas')
    meta.Session.add(p)
    s.pages.append(p)

    s = Subject('biologija', u'Biologijos pagrindai', LocationTag.get(u'vu'))
    p = Page(u'page title', u'Puslapio tekstas')
    s.pages.append(p)
    meta.Session.add(s)
    meta.Session.add(p)

    f = File(u'test.txt', u'geografija', 'text/txt')
    f.parent = s
    meta.Session.add(f)

    meta.Session.commit()
    meta.Session.execute("SET default_text_search_config TO 'public.lt'")


def tear_down(test):
    ututi.tests.tearDown(test)
