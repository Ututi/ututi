import string
import re

from sqlalchemy.sql import func, select
from sqlalchemy.sql.expression import or_, not_
from sqlalchemy.orm import aliased

from ututi.model import meta, SearchItem, LocationTag, ContentItem, TagSearchItem
from ututi.model import Group


def search_query_count(query):
    count = meta.Session.execute(
        select([func.count()], from_obj=query.with_labels().subquery())).scalar()
    return count

def search_query(**kwargs):
    """Prepare the search query according to the parameters given."""

    settings = {
        'text': None,
        'tags': None,
        'obj_type': None,
        'extra': None,
        'disjunctive': False,
        'use_rating': kwargs.get('obj_type', '*') == 'subject',
        'rank_cutoff': None,
        'limit': None}

    settings.update(kwargs)

    settings['text_original'] = settings['text']

    query = meta.Session.query(SearchItem)\
        .join(ContentItem)\
        .filter_by(deleted_by=None)

    if settings['text'] is not None:
        settings['text'] = _search_query_prepare_text(**settings)

    query = _search_query_text(query, **settings)

    query = _search_query_type(query, **settings)

    if isinstance(settings['tags'], basestring):
        settings['tags'] = settings['tags'].split(', ')
    query = _search_query_location_tags(query, settings)

    if settings['text'] is None:
        query = _search_query_default_sorting(query, **settings)
    else:
        query = _search_query_rank(query, **settings)

    if settings['extra'] is not None:
        query = settings['extra'](query)

    cnt = search_query_count(query)
    return query


def search(**kwargs):
    """
    A function that implements searching in the search_items table.

    The parameters are:
    text - the text string to search,
    tags - a list of tag titles,
    obj_type - the type to search for (accepted values: 'group', 'page', 'subject'),
    extra - external callback to run on the query before fetching results.
    disjunctive - if the query should be disjunctive (or), or conjunctive (and)
    """

    query = search_query(**kwargs)
    if kwargs.get('limit', None):
        query = query.limit(kwargs.get('limit'))
    return query.all()

def _search_query_prepare_text(**kwargs):
    text = kwargs.get('text')
    disjunctive = kwargs.get('disjunctive')
    regex = re.compile('[%s]' % re.escape(string.punctuation + string.whitespace))

    separator = ' | ' if disjunctive else ' & '

    text = [regex.sub('', st) for st in text.split(' ')]
    text = separator.join([st for st in text if len(st) > 1])
    return text

def _search_query_text(query, **kwargs):
    """Prepare the initial query, searching by text and ranking by the proximity."""

    language = kwargs.get('language')

    text = kwargs.get('text')
    if text:
        if language is not None:
            to_tsquery = func.to_tsquery(SearchItem.getDictForLanguage(language), text)
        else:
            to_tsquery = func.to_tsquery(text)
        query = query.filter(SearchItem.terms.op('@@')(to_tsquery))
    return query

def _search_query_rank(query, **kwargs):
    """
    Rank query results, sorting by search rank for most content types and
    integrating the rating for subjects.
    """
    rank_func = None
    text = kwargs.get('text')
    language = kwargs.get('language')
    rank_cutoff = kwargs.get('rank_cutoff')

    if language is not None:
        rank_func = func.ts_rank_cd(SearchItem.terms, func.to_tsquery(SearchItem.getDictForLanguage(language), text))
    else:
        rank_func = func.ts_rank_cd(SearchItem.terms, func.to_tsquery(text))

    if rank_cutoff is not None:
        query = query.filter(rank_func >= rank_cutoff)

    if kwargs.get('use_rating'):
        query = query.order_by((SearchItem.rating * rank_func).desc())
    else:
        query = query.order_by(rank_func.desc())
    return query

def _search_query_default_sorting(query, **kwargs):
    """
    Apply default ordering of results when no search string is specified.
    """
    obj_type = kwargs['obj_type']
    if obj_type in ['page', 'file', 'forum_post']:
        if not kwargs.get('grouped_search_items'):
            query = query.order_by(ContentItem.modified_on.desc())
    elif obj_type == 'group':
        if not kwargs.get('grouped_search_items'):
            query = query.join((Group, Group.id==SearchItem.content_item_id))
            query = query.order_by(Group.forum_is_public.desc(), ContentItem.modified_on.desc())
    elif obj_type == 'subject':
        query = query.order_by(SearchItem.rating.desc())
    return query

def _search_query_type(query, **kwargs):
    """Filter the query by object type."""
    obj_type = kwargs.get('obj_type')
    if obj_type is not None:
        if not isinstance(obj_type, list):
            obj_type = obj_type.split(',')

        query = query.filter(ContentItem.content_type.in_(obj_type))

    return query

def _search_query_location_tags(query, settings):
    """Filter the query by location tags."""

    tags = settings.get('tags')
    if tags is not None:
        parsed_tags = [] #storing processed tags here
        for tag_name in tags:
            #let's check each tag and see what we've got: a location tag or a simpletag
            ltag = LocationTag.get_all(tag_name)
            if ltag != []:
                # if it is a location tag, add not only it, but also its children
                location = []
                for ltag_item in ltag:
                    location.extend([lt.id for lt in ltag_item.flatten])
                parsed_tags.append(location)
            else:
                #a tag name that is not in the database was entered. Return empty list.
                return query.filter("false")

        if len(parsed_tags) > 0:
            intersect = None
            for location in parsed_tags:
                if intersect is None:
                    intersect = set(location)
                else:
                    intersect = intersect & set(location)
                query = query.filter(ContentItem.location_id.in_(list(location)))

    return query

def tag_search(text, count=5):
    """Search in the tag_search_items table (for location tags)."""
    QTag = aliased(LocationTag)
    QParent = aliased(LocationTag)
    text = text.lower().strip()
    query = meta.Session.query(TagSearchItem)\
        .join(QTag)\
        .outerjoin((QParent, QParent.id==QTag.parent_id))\
        .filter(TagSearchItem.terms.op('@@')(func.plainto_tsquery(text)))\
        .order_by(or_(func.lower(func.btrim(QParent.title)) == text, func.lower(func.btrim(QParent.title_short)) == text).desc())\
        .order_by(or_(func.lower(func.btrim(QTag.title)) == text, func.lower(func.btrim(QTag.title_short)) == text).desc())\
        .order_by(func.ts_rank_cd(TagSearchItem.terms, func.plainto_tsquery(text)))
    if count is not None:
        query = query.limit(count)
    return query.all()

def _exclude_subjects(sids):
    """A modifier for the subjects query, which excludes subjects already being watched."""
    def _filter(query):
        if not sids:
            return query
        return query.filter(not_(ContentItem.id.in_(sids)))
    return _filter
