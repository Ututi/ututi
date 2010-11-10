
from sqlalchemy.sql.expression import or_

from ututi.model import User
from ututi.model import Subject
from ututi.model import meta
from ututi.model import GroupMember
from ututi.model import Group


def _file_rcpt(term, current_user):
    """
    Return possible recipients for a file upload (for the current user).
    """
    groups = meta.Session.query(Group)\
        .filter(or_(Group.group_id.ilike('%%%s%%' % term),
                    Group.title.ilike('%%%s%%' % term)))\
        .filter(Group.id.in_([g.group.id for g in current_user.memberships]))\
        .all()

    subjects = meta.Session.query(Subject)\
        .filter(Subject.title.ilike('%%%s%%' % term))\
        .filter(Subject.id.in_([s.id for s in current_user.all_watched_subjects]))\
        .all()
    return (groups, subjects)


def _message_rcpt(term, current_user):
    """
    Return possible message recipients based on the query term.

    The idea is to first search for groups and classmates (members of the groups the user belongs to).

    If these are not found, we search for all users in general, limiting the results to 10 items.
    """

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


def _wiki_rcpt(term, current_user):
    """ Return possible wiki recipients based on the query term. """
    subjects = meta.Session.query(Subject)\
        .filter(Subject.title.ilike('%%%s%%' % term))\
        .filter(Subject.id.in_([s.id for s in current_user.all_watched_subjects]))\
        .all()
    return subjects
