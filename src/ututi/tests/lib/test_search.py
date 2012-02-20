from datetime import date
import doctest

from pylons import config

from ututi.model import LocationTag, GroupMembershipType, GroupMember, Group, User, meta
from ututi.model import meta, Subject, Page, SimpleTag, File

from ututi.tests import UtutiLayer
import ututi

from ututi.lib.search import search


def _query_filter(query):
    """A simple callback that limits the query to one result"""
    return query.limit(1)


def test_basic_search():
    r"""Tests basic searching by text contents.

    A basic test: we set up a group and search for its text.
    Set the indexing language first, something the controllers always do for us.

        >>> results = search(text=u'biologija', language=u'lt')
        >>> [result.object.title for result in results]
        [u'Bioinformatikai', u'Biology students', u'Biologijos pagrindai']

    Let's try out the lithuanian spelling:

        >>> [result.object.title for result in search(text=u'informatikos', language=u'lt')]
        [u'Bioinformatikai', u'Biology students']

    Let's try out the english spelling:

        >>> [result.object.title for result in search(text=u'biology', language=u'en')]
        [u'Biology students']

    Let's search for a subject and see what we get:

        >>> [result.object.title for result in search(text=u'biologija', obj_type='subject', language=u'lt')]
        [u'Biologijos pagrindai']

    Let's try out the external query callback support:

        >>> [result.object.title for result in search(text=u'biologija', extra=_query_filter, language=u'lt')]
        [u'Bioinformatikai']

    Let's filter by type:
        >>> [result.object.title for result in search(text=u'biologija', obj_type='group', language=u'lt')]
        [u'Bioinformatikai', u'Biology students']

    No pages have been added yet:
        >>> [result.object.title for result in search(text=u'biologija', obj_type='page', language=u'lt')]
        []

    Test file search:
        >>> results = search(text=u'geografija')
        >>> [result.object.title for result in results]
        [u'geografija']

    """

def test_search_regressions():
    """
    Disjunctive double spaces don't break search:

        >>> results = search(text=u'biologija  informatika', disjunctive=True, language=u'lt')
        >>> [result.object.title for result in results]
        [u'Bioinformatikai', u'Biology students', u'Biologijos pagrindai']

    """

def test_location_search():
    """Testing filtering by location.

        >>> sorted([result.object.title for result in search(tags=[u'vu'], language=u'lt')])
        [u'Biologijos pagrindai', u'Biology students', u'Test subject', u'geografija', u'page title', u'page title']

        >>> sorted([result.object.title for result in search(tags=[u'ef'], language=u'lt')])
        [u'Biology students', u'Ekologai']

    Intersecting this tag with its parent tag should get us only the intersection.
        >>> sorted([result.object.title for result in search(tags=[u'vu', u'ef'], language=u'lt')])
        [u'Biology students']

        >>> sorted([result.object.title for result in search(tags=[u'ef', u'ktu'], language=u'lt')])
        [u'Ekologai']

    Let's search for a non-existant tag.

        >>> [result.object.title for result in search(tags=[u'noneversity'], language=u'lt')]
        []

    Take a look at the rating just cause they are here:
        >>> [(result.rating, result.object.title) for result in search(text=u'pagrindai', obj_type='subject', language=u'lt')]
        [(2, u'Biologijos pagrindai'), (1, u'Test subject')]

    """

def test_suite():
    suite = doctest.DocTestSuite(
        optionflags=doctest.ELLIPSIS | doctest.REPORT_UDIFF |
        doctest.NORMALIZE_WHITESPACE,
        setUp=test_setup,
        tearDown=tear_down)
    suite.layer = UtutiLayer
    return suite


def test_setup(test):
    """Create some models needed for the tests."""
    ututi.tests.setUp(test)
    from ututi.model import initialize_dictionaries
    initialize_dictionaries(meta.engine)

    vu = LocationTag(u'Vilniaus universitetas', u'vu', u'', member_policy='PUBLIC')
    ef = LocationTag(u'Ekonomikos fakultetas', u'ef', u'', vu, member_policy='PUBLIC')

    meta.Session.add(vu)
    meta.Session.add(ef)

    # We need someone who can create subjects and groups
    user = User(u'User', 'user@vu.ututi.com', vu, 'password')
    meta.Session.add(user)
    meta.Session.commit()

    meta.Session.execute("SET default_text_search_config TO 'public.universal'")
    meta.set_active_user(user.id)

    l = LocationTag(u'Kauno technologijos universitetas', u'ktu', u'', member_policy='PUBLIC')
    f = LocationTag(u'Ekologijos fakultetas', u'ef', u'', l, member_policy='PUBLIC')

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
    meta.Session.execute("SET default_text_search_config TO 'public.universal'")


def tear_down(test):
    ututi.tests.tearDown(test)
