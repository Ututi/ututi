from sqlalchemy.sql.expression import not_
from sqlalchemy.sql.expression import or_, and_
from sqlalchemy.sql import select

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
        t_evt_comments = meta.metadata.tables['event_comments']
        t_wall_posts = meta.metadata.tables['wall_posts']
        t_content_items = meta.metadata.tables['content_items']
        subject_ids = [s.id for s in subjects]
        group_ids = [m.group.id for m in c.user.memberships]
        user_commented_evts_select = select([t_evt_comments.c.event_id],
                                            from_obj=[t_evt_comments.join(t_content_items,
                                                                          t_content_items.c.id == t_evt_comments.c.id)],)\
            .where(t_content_items.c.created_by == c.user.id)
        user_commented_evts = map(lambda r: r[0], meta.Session.execute(user_commented_evts_select).fetchall())

        query = evts_generic\
            .where(or_(or_(t_evt.c.object_id.in_(subject_ids),
                           t_wall_posts.c.subject_id.in_(subject_ids)) if subject_ids else False,  # subject wall posts
                       and_(or_(t_evt.c.author_id == c.user.id,  # location wall posts
                                # XXX User comments may grow to 1k-10k scale, consider a different implementation.
                                t_evt.c.id.in_(user_commented_evts) if user_commented_evts else False),
                            t_evt.c.event_type.in_(('subject_wall_post', 'location_wall_post'))),
                       or_(t_evt.c.object_id.in_(group_ids),) if group_ids else False))\
            .where(or_(t_evt.c.event_type != 'moderated_post_created',
                       t_evt.c.object_id.in_(user_is_admin_of_groups) if user_is_admin_of_groups else False))\
            .where(not_(t_evt.c.event_type.in_(c.user.ignored_events_list) if c.user.ignored_events_list else False))

        return query
