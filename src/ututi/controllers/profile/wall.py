from pylons import tmpl_context as c

from ututi.lib.wall import WallMixin


class UserWallMixin(WallMixin):

    def _wall_events_query(self):
        return c.user.get_wall_events_query()
