import logging

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import or_, and_
from pylons.controllers.util import abort, redirect
from pylons import tmpl_context as c, request, url
from routes.util import url_for

from pylons.i18n import _

from ututi.controllers.home import sign_in_user
from ututi.lib.security import ActionProtector, deny
from ututi.lib.image import serve_logo
from ututi.lib.base import BaseController, render
from ututi.lib.wall import WallMixin

from ututi.model import meta, User, Medal, ContentItem
from ututi.model.events import Event
from ututi.model.users import Teacher

log = logging.getLogger(__name__)


def profile_action(method):
    def _profile_action(self, id):
        try:
            id = int(id)
        except ValueError:
            abort(404)

        user = User.get_byid(id)
        c.user_info = user
        if user is None:
            abort(404)
        return method(self, user)
    return _profile_action

class UserInfoWallMixin(WallMixin):

    def _wall_events_query(self):
        """WallMixin implementation."""
        public_event_types = [
            'group_created',
            'subject_created',
            'subject_modified',
            'page_created',
            'page_modified',
        ]
        from ututi.lib.wall import generic_events_query
        t_evt = meta.metadata.tables['events']
        t_ci = meta.metadata.tables['content_items']
        evts_generic = generic_events_query()

        query = evts_generic\
            .where(and_(t_evt.c.author_id == c.user_info.id,
                        or_(t_evt.c.event_type.in_(public_event_types),
                            and_(t_evt.c.event_type == 'file_uploaded',
                                 t_ci.c.content_type == 'subject'))))

        return query

class UserController(BaseController, UserInfoWallMixin):

    @profile_action
    def index(self, user):
        if not user.profile_is_public and not c.user:
            deny(_('This user profile is not public'), 401)

        c.breadcrumbs = [
            {'title': user.fullname,
             'link': url_for(controller='user', action='index', id=user.id)}
            ]

        self._set_wall_variables(events_hidable=False)

        if user.is_teacher:
            if user.location:
                location_ids = [loc.id for loc in user.location.flatten]
                c.all_teachers = meta.Session.query(Teacher)\
                    .filter(Teacher.id != user.id)\
                    .filter(Teacher.location_id.in_(location_ids))\
                    .order_by(Teacher.fullname).all()
            else:
                c.all_teachers = []
            return render('user/teacher_profile.mako')
        else:
            return render('user/index.mako')

    @profile_action
    @ActionProtector("root")
    def login_as(self, user):
        sign_in_user(user)
        redirect(url(controller='profile', action='home'))

    @profile_action
    @ActionProtector("root")
    def medals(self, user):
        c.user_info = user
        c.available_medals = [Medal(None, m[0])
                              for m in Medal.available_medals()]
        return render('user/medals.mako')

    @profile_action
    @ActionProtector("root")
    def award_medal(self, user):
        try:
            medal_type = request.GET['medal_type']
        except KeyError:
            abort(404)
        if medal_type not in Medal.available_medal_types():
            abort(404)
        if medal_type in [m.medal_type for m in user.medals]:
            redirect(url.current(action='medals')) # Medal already granted.
        m = Medal(user, medal_type)
        meta.Session.add(m)
        meta.Session.commit()
        redirect(url.current(action='medals'))

    @profile_action
    @ActionProtector("root")
    def take_away_medal(self, user):
        try:
            medal_id = int(request.GET['medal_id'])
        except KeyError:
            abort(404)
        try:
            medal = meta.Session.query(Medal).filter_by(id=medal_id).one()
        except NoResultFound:
            redirect(url.current(action='medals')) # Medal has been already taken away.
        if medal.user is not user:
            abort(404)
        meta.Session.delete(medal)
        meta.Session.commit()
        redirect(url.current(action='medals'))

    def logo(self, id, width=None, height=None):
        user = User.get_global(int(id))
        if user is None:
            abort(404)

        if user.is_teacher:
            img_path = 'public/img/teacher_60x60.png'
            width = 60
        else:
            img_path = 'public/img/user_default.png'

        return serve_logo('user', int(id), width=width, square=True,
                          default_img_path=img_path, cache=False)
