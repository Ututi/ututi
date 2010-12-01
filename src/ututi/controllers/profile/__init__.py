import logging

from ututi.model.users import Teacher
from ututi.lib.base import BaseController
from ututi.lib.security import current_user
from ututi.controllers.profile.controllers import UserProfileController, TeacherProfileController

log = logging.getLogger(__name__)

class ProfileController(BaseController):
    """
    This is the generic profile controller.
    All interactions are handled by either the UserProfileController
    of the TeacherProfileController, depending on the user.
    """

    def __new__(self):
        user = current_user()
        if isinstance(user, Teacher):
            return TeacherProfileController()
        else:
            return UserProfileController()
