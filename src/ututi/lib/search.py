from ututi.model import meta, SearchItem, SimpleTag, LocationTag, ContentItem, TagSearchItem
import logging

from sqlalchemy.sql import func, select
from sqlalchemy.sql.expression import or_
from sqlalchemy.orm import aliased

import pylons

log = logging.getLogger(__name__)

def search_query_count(query):
    count = meta.Session.execute(select([func.count()], from_obj=query.subquery())).scalar()
    return count

def search_query(**kwargs):
    """Prepare the search query according to the parameters given."""

    settings = {
        'text': None,
        'tags': None,
        'type': None,
        'extra': None,
        'disjunctive': False,
        'use_rating': kwargs.get('type', '*') == 'subject',
        'rank_cutoff': None,
        'limit': None}

    settings.update(kwargs)

    query = meta.Session.query(SearchItem)\
        .join(ContentItem)\
        .filter_by(deleted_by=None)

    query = _search_query_text(query, **settings)

    query = _search_query_type(query, **settings)

    if isinstance(settings['tags'], basestring):
        settings['tags'] = settings['tags'].split(', ')
    query = _search_query_tags(query, **settings)

    query = _search_query_rank(query, **settings)

    if settings['extra'] is not None:
        query = settings['extra'](query)

    cnt = search_query_count(query)
    log_msg = u"%(url)s \t %(text)s \t %(tags)s \t %(type)s \t %(count)i" % {"url": '', # pylons.url.current(),
                                                                             "text": settings['text'] is not None and settings['text'] or '',
                                                                             "tags": settings['tags'] is not None and ', '.join(settings['tags']) or '',
                                                                             "type": settings['type'] is not None or '*',
                                                                             "count": cnt }
    if cnt == 0:
        log.warn(log_msg)
    else:
        log.info(log_msg)
    return query


def search(**kwargs):
    """
    A function that implements searching in the search_items table.

    The parameters are:
    text - the text string to search,
    tags - a list of tag titles,
    type - the type to search for (accepted values: 'group', 'page', 'subject'),
    extra - external callback to run on the query before fetching results.
    disjunctive - if the query should be disjunctive (or), or conjunctive (and)
    """
    query = search_query(**kwargs)
    if kwargs.get('limit', None):
        query = query.limit(kwargs.get('limit'))
    return query.all()

def _search_query_text(query, **kwargs):
    """Prepare the initial query, searching by text and ranking by the proximity."""

    text = kwargs.get('text')
    disjunctive = kwargs.get('disjunctive')
    if text:
        if disjunctive:
            text = text.replace(' ', ' | ')
            query = query.filter(SearchItem.terms.op('@@')(func.to_tsquery(text)))
        else:
            query = query.filter(SearchItem.terms.op('@@')(func.plainto_tsquery(text)))
    return query

def _search_query_rank(query, **kwargs):
    """
    Rank query results, sorting by search rank for most content types and
    integrating the rating for subjects.
    """
    rank_func = None
    text = kwargs.get('text')
    disjunctive = kwargs.get('disjunctive')

    if disjunctive:
        text = text.replace(' ', ' | ')
        rank_func = func.ts_rank_cd(SearchItem.terms, func.to_tsquery(text))
    else:
        rank_func = func.ts_rank_cd(SearchItem.terms, func.plainto_tsquery(text))

    if kwargs.get('use_rating'):
        query = query.order_by((SearchItem.rating * rank_func).desc())
    else:
        query = query.order_by(rank_func.desc())
    return query

def _search_query_type(query, **kwargs):
    """Filter the query by object type."""
    obj_type = kwargs.get('type')
    if obj_type is not None:
        query = query.filter(ContentItem.content_type == obj_type)

    return query

def _search_query_tags(query, **kwargs):
    """Filter the query by tags."""

    tags = kwargs.get('tags')
    if tags is not None:
        stags = [] #simple tags
        ltags = [] #location tags
        mtags = [] #mixed tags - an unconvenient reality, tags that match bot locations and simple tags by title
        for tag_name in tags:
            #let's check each tag and see what we've got: a location tag or a simpletag
            tag = SimpleTag.get(tag_name, False)
            ltag = LocationTag.get_all(tag_name)
            if ltag != [] and tag is not None:
                #we have a mixed tag - one that matches both a location tag and a simple tag
                location = []
                for ltag_item in ltag:
                    location.extend([lt.id for lt in ltag_item.flatten])

                mtags.append(dict(ltag=location, tag=tag.id))
            elif ltag != []:
                # if it is a location tag, add not only it, but also its children
                location = []
                for ltag_item in ltag:
                    location.extend([lt.id for lt in ltag_item.flatten])
                ltags.append(location)
            elif tag is not None:
                stags.append(tag.id)
            else:
                #a tag name that is not in the database was entered. Return empty list.
                return query.filter("false")

        if len(stags) > 0:
            query = query.join(ContentItem.tags).filter(SimpleTag.id.in_(stags)).group_by(SearchItem).having(func.count(SearchItem.content_item_id) == len(stags))

        if len(ltags) > 0:
            intersect = None
            for location in ltags:
                if intersect is None:
                    intersect = set(location)
                else:
                    intersect = intersect & set(location)
                query = query.filter(ContentItem.location_id.in_(list(location)))

        if len(mtags) > 0:
            query = query.outerjoin(ContentItem.tags)
            for mtag in mtags:
                query = query.filter(or_(SimpleTag.id == mtag['tag'], ContentItem.location_id.in_(list(mtag['ltag']))))

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
