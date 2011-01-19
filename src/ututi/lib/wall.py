from pylons.decorators import jsonify
from pylons import request
from pylons import tmpl_context as c
from pylons.i18n import _

from sqlalchemy.orm.query import aliased
from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import func
from sqlalchemy.sql.expression import select

from ututi.lib.security import ActionProtector
from ututi.model import User, meta, GroupMember, Group, Subject
from ututi.model.events import Event

def _message_rcpt(term, current_user):
    """Return list of possible recipients limited by the query term."""

    groups = meta.Session.query(Group)\
        .filter(or_(Group.group_id.ilike('%%%s%%' % term),
                    Group.title.ilike('%%%s%%' % term)))\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .all()

    classmates = meta.Session.query(User)\
        .filter(User.fullname.ilike('%%%s%%' % term))\
        .join(User.memberships)\
        .join(GroupMember.group)\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .all()

    users = []
    if len(groups) == 0 and len(classmates) == 0:
        users = meta.Session.query(User)\
            .filter(User.fullname.ilike('%%%s%%' % term))\
            .limit(10)\
            .all()

    return (groups, classmates, users)

class WallMixin(object):

    def _wall_events_query(self):
        """Should be implemented by subclasses."""
        raise NotImplementedError()

    def _wall_events(self, limit=60):
        """Returns threaded events, defined by _wall_events_query()"""

        #query for ordering events by their last subevent
        e = aliased(Event)
        child_query = select([e.created], e.parent_id==Event.id, order_by=e.created.desc(), limit=1).label('last')

        event_query = self._wall_events_query()

        return event_query\
            .filter(Event.parent == None)\
            .order_by(func.coalesce(child_query, Event.created).desc(),
                      Event.event_type)\
            .limit(limit).all()

    def _message_rcpt(self, term, current_user):
        """May be overridden by subclasses.
        return (groups, classmates, users) based on a query term."""
        return _message_rcpt(term, current_user)

    def _file_rcpt(self):
        """May be overridden by subclasses.
        return list of (prefixed id, title),
        e.g. ('g_1', 'Group: Moderators')"""
        groups = meta.Session.query(Group)\
            .filter(Group.id.in_([g.group.id for g in c.user.memberships]))\
            .filter(Group.has_file_area == True)\
            .order_by(Group.title.asc())\
            .all()

        subjects = meta.Session.query(Subject)\
            .filter(Subject.id.in_([s.id for s in c.user.all_watched_subjects]))\
            .order_by(Subject.title.asc())\
            .all()

        items = []
        for group in groups:
            items.append(('g_%d' % group.id, _('Group: %s') % group.title))

        for subject in subjects:
            items.append(('s_%d' % subject.id, _('Subject: %s') % subject.title))
        return items

    def _wiki_rcpt(self):
        """May be overridden by subclasses.
        return list of (subject.id, subject.title)"""
        return [(subject.id, subject.title)
                for subject in c.user.all_watched_subjects]

    def _set_wall_variables(self, events_hidable=False):
        """This is just a shorthand method for setting common
        wall variables."""
        c.events = self._wall_events()
        c.events_hidable = events_hidable
        c.file_recipients = self._file_rcpt()
        c.wiki_recipients = self._wiki_rcpt()

    @ActionProtector("user")
    @jsonify
    def message_rcpt_js(self):
        term = request.params.get('term', None)
        if term is None or len(term) < 1:
            return {'data' : []}

        (groups, classmates, others) = self._message_rcpt(term, c.user)

        groups = [
            dict(label=_('Group: %s') % group.title,
                 id='g_%d' % group.id,
                 categories=[dict(value=cat.id, title=cat.title)
                             for cat in group.forum_categories]
                             if not group.mailinglist_enabled else [])
            for group in groups]

        classmates = [dict(label=_('Member: %s (%s)') % (u.fullname, u.emails[0].email),
                           id='u_%d'%u.id) for u in classmates]
        users = [dict(label=_('Member: %s') % (u.fullname),
                      id='u_%d' % u.id) for u in others]
        return dict(data=groups+classmates+users)
