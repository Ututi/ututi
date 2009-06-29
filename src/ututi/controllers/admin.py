import logging

from datetime import date
from pylons import request, c
from pylons.controllers.util import redirect_to, abort
from sqlalchemy.orm.exc import NoResultFound
from ututi.lib.base import BaseController, render
from ututi.lib import current_user

from ututi.model import meta, User, Email, LocationTag, Group, Subject

log = logging.getLogger(__name__)

import csv
import os

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
                user = User.get(email)
                if user is None:
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

    def import_groups(self):
        file = request.POST.get('file_upload', None)

        if file is not None and file != '':
            csv_reader = csv.reader(file.value.split(os.linesep))
            for row in csv_reader:
                if len(row) < 4:
                    continue

                id, title, desc, year = row[:4]
                try:
                    group = meta.Session.query(Group).filter_by(id = id).one()
                except NoResultFound:
                    group = Group(id = id)
                    meta.Session.add(group)

                group.title = title
                group.description = desc
                if year != '':
                    group.year = date(int(year), 1, 1)
                else:
                    group.year = date.today()
                meta.Session.commit()
        redirect_to(controller='group', action='index')

    def import_subjects(self):
        file = request.POST.get('file_upload', None)

        if file is not None and file != '':
            csv_reader = csv.reader(file.value.split(os.linesep))
            for row in csv_reader:
                if len(row) < 3:
                    continue

                id, title, lecturer = row[:3]
                try:
                    subj = meta.Session.query(Subject).filter_by(text_id = id).one()
                    subj = Subject(title) #the pretty url is being used - forget it
                    meta.Session.add(subj)
                except NoResultFound:
                    subj = Subject(title, text_id = id)
                    meta.Session.add(subj)

                if lecturer is not None:
                    subj.lecturer = lecturer

                meta.Session.commit()
        redirect_to(controller='subject', action='index')
