from sqlalchemy.sql.expression import and_
from sqlalchemy.sql.expression import or_

from pylons import tmpl_context as c

from ututi.model import meta
from ututi.model.events import Event

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

        query = meta.Session.query(Event)\
             .filter(or_(Event.object_id.in_([s.id for s in subjects]),
                         Event.object_id.in_([m.group.id for m in c.user.memberships]),
                         Event.recipient_id == c.user.id,
                         and_(Event.event_type=='private_message_sent',
                              Event.user == c.user)))\
             .filter(or_(Event.event_type != 'moderated_post_created',
                         Event.object_id.in_(user_is_admin_of_groups)))\
             .filter(~Event.event_type.in_(c.user.ignored_events_list))

        return query

