
from pylons import url
from ututi.lib.wall import WallMixin
from ututi.lib.fileview import FileViewMixin

class ProfileWallController(WallMixin, FileViewMixin):
    def _redirect_url(self):
        """This is the default redirect url of wall methods.
           Subclasses should override it."""
        return url(controller='profile', action='wall')


