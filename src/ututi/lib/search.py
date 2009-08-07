from ututi.model import meta, SearchItem, SimpleTag, LocationTag, ContentItem

from sqlalchemy.sql import func

def search_query(text=None, tags=None, obj_type=None, extra=None):
    """Prepare the search query according to the parameters given."""

    query = meta.Session.query(SearchItem).join(ContentItem)

    query = _search_query_text(query, text)

    query = _search_query_type(query, obj_type)

    query = _search_query_tags(query, tags)

    if extra is not None:
        query = extra(query)
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
        query = query.filter("terms @@ plainto_tsquery('%s')" % text)\
            .order_by("ts_rank_cd(terms, plainto_tsquery('%s'))" % text)
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
        for tag_name in tags:
            #let's check each tag and see what we've got: a location tag or a simpletag
            tag = SimpleTag.get(tag_name, False)
            ltag = LocationTag.get_by_title(tag_name)
            if tag is not None:
                stags.append(tag.id)
            elif ltag is not None:
                # if it is a location tag, add not only it, but also its children
                ltags.extend([lt.id for lt in ltag.flatten()])
            else:
                #a tag name that is not in the database was entered. Return empty list.
                return query.filter("false")

        if len(stags) > 0:
            query = query.join(ContentItem.tags).filter(SimpleTag.id.in_(stags)).group_by(SearchItem).having(func.count(SearchItem.content_item_id) == len(stags))

        if len(ltags) > 0:
            query = query.filter(ContentItem.location_id.in_(ltags))
    return query
