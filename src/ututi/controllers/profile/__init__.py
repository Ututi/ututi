import logging

from ututi.model.users import Teacher
from ututi.lib.security import current_user
from ututi.controllers.profile.user import UserProfileController
from ututi.controllers.profile.teacher import TeacherProfileController, \
        UnverifiedTeacherProfileController

log = logging.getLogger(__name__)

def ProfileController():
    """
    This is the generic profile controller.
    All interactions are handled by either the UserProfileController
    of the TeacherProfileController, depending on the user.
    """
    user = current_user()
    if isinstance(user, Teacher):
        if not user.teacher_verified:
            return UnverifiedTeacherProfileController()
        return TeacherProfileController()
    else:
        return UserProfileController()

ProfileController.__bases__ = []
