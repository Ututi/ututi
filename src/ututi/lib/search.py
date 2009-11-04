from ututi.model import meta, SearchItem, SimpleTag, LocationTag, ContentItem
import logging

from sqlalchemy.sql import func, select
from sqlalchemy.sql.expression import or_
import pylons

log = logging.getLogger(__name__)

def search_query_count(query):
    count = meta.Session.execute(select([func.count()], from_obj=query.subquery())).scalar()
    return count

def search_query(text=None, tags=None, obj_type=None, extra=None):
    """Prepare the search query according to the parameters given."""

    query = meta.Session.query(SearchItem)\
        .join(ContentItem)\
        .filter_by(deleted_by=None)

    query = _search_query_text(query, text)

    query = _search_query_type(query, obj_type)

    if isinstance(tags, basestring):
        tags = tags.split(', ')
    query = _search_query_tags(query, tags)

    if extra is not None:
        query = extra(query)

    cnt = search_query_count(query)
    log_msg = u"%(url)s \t %(text)s \t %(tags)s \t %(type)s \t %(count)i" % {"url": pylons.url.current(),
                                                                             "text": text is not None and text or '',
                                                                             "tags": tags is not None and ', '.join(tags) or '',
                                                                             "type": obj_type is not None or '*',
                                                                             "count": cnt }
    if cnt == 0:
        log.warn(log_msg)
    else:
        log.info(log_msg)
    return query


def search(text=None, tags=None, type=None, extra=None):
    """
    A function that implements searching in the search_items table.

    The parameters are:
    text - the text string to search,
    tags - a list of tag titles,
    type - the type to search for (accepted values: 'group', 'page', 'subject'),
    external - external callback to run on the query before fetching results.
    """

    query = search_query(text, tags, type, extra)
    return query.all()


def _search_query_text(query, text=None):
    """Prepare the initial query, searching by text and ranking by the proximity."""

    if text is not None:
        query = query.filter(SearchItem.terms.op('@@')(func.plainto_tsquery(text)))\
            .order_by(func.ts_rank_cd(SearchItem.terms, func.plainto_tsquery(text)))
    return query

def _search_query_type(query, obj_type):
    """Filter the query by object type."""
    if obj_type is not None:
        query = query.filter(ContentItem.content_type == obj_type)

    return query

def _search_query_tags(query, tags):
    """Filter the query by tags."""

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
