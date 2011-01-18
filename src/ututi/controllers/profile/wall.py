from pylons import url
from pylons import tmpl_context as c
from ututi.lib.wall import WallMixin
from ututi.lib.fileview import FileViewMixin

from ututi.model import meta
from ututi.model.events import Event

from sqlalchemy.orm.query import aliased
from sqlalchemy.sql.expression import select
from sqlalchemy.sql.expression import func
from sqlalchemy.sql.expression import and_
from sqlalchemy.sql.expression import or_

class ProfileWallController(WallMixin, FileViewMixin):

    def _redirect_url(self, id=None):
        return url(controller='profile', action='wall')


    def _wall_events(self, limit=60):
        user_is_admin_of_groups = [membership.group_id
                                   for membership in c.user.memberships
                                   if membership.membership_type == 'administrator']
        e = aliased(Event)

        subjects = c.user.all_watched_subjects
        if c.user.is_teacher:
            subjects += c.user.taught_subjects

        #query for ordering events by their last subevent
        child_query = select([e.created], e.parent_id==Event.id, order_by=e.created.desc(), limit=1).label('last')

        q = meta.Session.query(Event)\
             .filter(or_(Event.object_id.in_([s.id for s in subjects]),
                         Event.object_id.in_([m.group.id for m in c.user.memberships]),
                         Event.recipient_id == c.user.id,
                         and_(Event.event_type=='private_message_sent',
                              Event.user == c.user)))\
             .filter(or_(Event.event_type != 'moderated_post_created',
                         Event.object_id.in_(user_is_admin_of_groups)))\
             .filter(~Event.event_type.in_(c.user.ignored_events_list))\
             .filter(Event.parent == None)\
             .order_by(func.coalesce(child_query, Event.created).desc(),
                       Event.event_type)

        return q.limit(limit).all()
