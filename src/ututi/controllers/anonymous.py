from ututi.lib.base import BaseController
from ututi.lib.image import serve_logo

class AnonymousController(BaseController):

    def logo(self, width=None, height=None):
        return serve_logo('user', width=width, height=height,
                default_img_path="public/images/details/icon_user.png",
                cache=False)

