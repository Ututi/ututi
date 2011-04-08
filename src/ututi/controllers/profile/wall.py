from sqlalchemy.sql.expression import not_
from sqlalchemy.sql.expression import or_

from pylons import tmpl_context as c

from ututi.model import meta

from ututi.lib.wall import WallMixin

class UserWallMixin(WallMixin):

    def _wall_events_query(self):
        """WallMixin implementation."""
        user_is_admin_of_groups = [membership.group_id
                                   for membership in c.user.memberships
                                   if membership.membership_type == 'administrator']
        subjects = c.user.all_watched_subjects
        if c.user.is_teacher:
            subjects += c.user.taught_subjects
        from ututi.lib.wall import generic_events_query
        evts_generic = generic_events_query()

        t_evt = meta.metadata.tables['events']
        query = evts_generic\
             .where(or_(t_evt.c.object_id.in_([s.id for s in subjects]),
                        t_evt.c.object_id.in_([m.group.id for m in c.user.memberships])))\
             .where(or_(t_evt.c.event_type != 'moderated_post_created',
                         t_evt.c.object_id.in_(user_is_admin_of_groups)))\
             .where(not_(t_evt.c.event_type.in_(c.user.ignored_events_list)))

        return query

