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
        subject_ids = [s.id for s in subjects]
        group_ids = [m.group.id for m in c.user.memberships]
        query = evts_generic\
             .where(or_(t_evt.c.object_id.in_(subject_ids) if subject_ids else False,
                        t_evt.c.object_id.in_(group_ids) if group_ids else False))\
             .where(or_(t_evt.c.event_type != 'moderated_post_created',
                         t_evt.c.object_id.in_(user_is_admin_of_groups) if user_is_admin_of_groups else False))\
             .where(not_(t_evt.c.event_type.in_(c.user.ignored_events_list) if c.user.ignored_events_list else False))

        return query

