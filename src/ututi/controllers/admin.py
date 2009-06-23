import logging

from pylons import request, c
from pylons.controllers.util import redirect_to, abort
from sqlalchemy.orm.exc import NoResultFound
from ututi.lib.base import BaseController, render
from ututi.lib import current_user

from ututi.model import meta, User, Email, LocationTag

log = logging.getLogger(__name__)


class AdminController(BaseController):
    """Controler for system administration."""

    def index(self):
        user = current_user()
        if user is None:
            abort(401, 'You are not authenticated')
        return render('/admin/import.mako')

    def users(self):
        user = current_user()
        if user is None:
            abort(401, 'You are not authenticated')

        c.users = meta.Session.query(User).all()
        return render('/admin/users.mako')

    def import_users(self):
        file = request.POST.get('file_upload', None)

        if file is not None and file != '':
            for line in file.value.split('\n'):
                if line.strip() == '':
                    continue
                line = line.strip().split(',')
                fullname = line[2].strip()
                password = line[1].strip()[6:]
                email = line[3].strip().lower()
                try:
                    user = meta.Session.query(Email).filter_by(email = email).one().user
                except NoResultFound:
                    user = User(fullname, password, False)
                    user.emails = [Email(email)]
                    meta.Session.add(user)

                meta.Session.commit()
        redirect_to(controller='admin', action='users')

    def import_structure(self):
        file = request.POST.get('file_upload', None)

        if file is not None and file != '':
            for line in file.value.split('\n'):
                if line.strip() == '':
                    continue
                line = line.strip().split(',')
                title = line[1].strip()
                title_short = line[0].strip().lower()
                description = line[2].strip()
                parent = line[3].strip().lower()
                try:
                    if parent == '':
                        tag = meta.Session.query(LocationTag).filter_by(title_short = title_short)\
                            .filter_by(parent = None).one()
                    else:
                        tag = meta.Session.query(LocationTag).filter(LocationTag.title_short==title_short)\
                            .join('parent_item', aliased=True).filter(LocationTag.title_short==parent)\
                            .one()
                except NoResultFound:
                    tag = LocationTag(title = title,
                                      title_short = title_short,
                                      description = description)
                tag.title = title
                tag.title_short = title_short
                tag.description = description

                meta.Session.add(tag)
                if parent != '':
                    try:
                        parent = meta.Session.query(LocationTag).filter_by(title_short=parent).one()
                        parent.children.append(tag)
                    except NoResultFound:
                        continue
                meta.Session.commit()
        redirect_to(controller='structure', action='index')
