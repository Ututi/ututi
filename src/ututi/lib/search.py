from ututi.model import meta, SearchItem, SimpleTag, LocationTag

from sqlalchemy.sql import select, func
from sqlalchemy.sql.expression import and_, or_

def search(text=None, tags=None, type=None):
    """
    A function that implements searching in the search_items table.

    The parameters are:
    text - the text string to search,
    tags - a list of tag titles,
    type - the type to search for (accepted values: 'group', 'page', 'subject').
    """
    #XXX: filtering by tags is not implemented yet.
    from ututi.model import content_tags_table as ttbl, search_items_table as stbl

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
                return []

        if len(stags) > 0:
            tag_query = select([ttbl.c.page_id,
                                ttbl.c.group_id,
                                ttbl.c.subject_id,
                                ttbl.c.subject_location_id])

            tag_query = tag_query.where(ttbl.c.tag_id.in_(stags))
            tag_query = tag_query.group_by(tag_query.c.group_id,
                                           tag_query.c.page_id,
                                           tag_query.c.subject_id,
                                           tag_query.c.subject_location_id)
            tag_query = tag_query.having(func.count(ttbl.c.id) == len(stags)).alias()

            query = query.join((tag_query,
                                or_(stbl.c.group_id == tag_query.c.group_id,
                                     stbl.c.page_id == tag_query.c.page_id,
                                    and_(stbl.c.subject_id == tag_query.c.subject_id,
                                         stbl.c.subject_location_id == tag_query.c.subject_location_id))))

        if len(ltags) > 0:
            query = query.filter(stbl.c.location_id.in_(ltags))

    return query.all()
