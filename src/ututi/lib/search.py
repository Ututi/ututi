from ututi.model import meta, SearchItem
from sqlalchemy.sql.expression import and_

def search(text=None, tags=None, type=None):
    """
    A function that implements searching in the search_items table.

    The parameters are:
    text - the text string to search,
    tags - a list of tag titles,
    type - the type to search for (accepted values: 'group', 'page', 'subject').
    """
    #XXX: filtering by tags is not implemented yet.

    query = meta.Session.query(SearchItem)

    if text is not None and isinstance(text, unicode):
        ts = "terms @@ plainto_tsquery('%s')" % text
        query = query.filter(ts)

    if type is not None:
        if type == 'group':
            query = query.filter("not group_id is null")
        elif type == 'subject':
            query = query.filter(and_("not subject_id is null", "not subject_location_id is null"))
        elif type == 'page':
            query = query.filter("not page_id is null")

    return query.all()
