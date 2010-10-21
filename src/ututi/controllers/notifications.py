from ututi.model import meta, Notification, User
from pylons import request
from ututi.lib.base import BaseController
from ututi.lib.security import ActionProtector

class NotificationsController(BaseController):
    """Notifications Controller handeling notification messages displaying for user"""

    @ActionProtector("user")
    def set_notification_as_viewed(self, id):
       user_id = request.params['user_id']
       notification = meta.Session.query(Notification).filter(Notification.id == id).one()
       user = meta.Session.query(User).filter(User.id==user_id).one()
       notification.users.append(user)
       meta.Session.commit()
