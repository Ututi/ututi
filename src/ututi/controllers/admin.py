import csv
import string
import os
import logging
import base64

from magic import from_buffer
from datetime import date

from pylons import request, c
from pylons.controllers.util import redirect_to, abort

from random import Random
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.model import SimpleTag
from ututi.model import UserSubjectMonitoring
from ututi.model import Page
from ututi.model import (meta, User, Email, LocationTag, Group, Subject,
                         GroupMember, GroupMembershipType, File)

log = logging.getLogger(__name__)

email_map = {'inf@mytutor.lt'             : 'info@mytutor.lt',
             'indremilukaite@gmai.com'    : 'indremilukaite@gmail.com',
             'svaras456@gmai.com'         : 'svaras456@gmail.com',
             'veju.mote@gmsil.com'        : 'dainius1989@gmail.com',
             'dainius1989@gnail.com'      : 'veju.mote@gmail.com',
             'jurgis.pragauskis@gmail.com': 'jurgis.pralgauskis@gmail.com',
             'jarekass+petras@takas.lt'   : '',
             'asta.samulionyte@khf.vu.lt' : '',
             'jana89@one.lt'              : '',
             'info@ututi.lt'              : '',
             'ted.bing@gmail.com'         : ''}


def store_file(file_obj, file_name):
    path = os.environ.get("upload_import_path", None)
    if path is not None:
        file_obj.store(open(os.path.join(path, file_name)))
    else:
        file_obj.store('Whatever!')


class AdminController(BaseController):
    """Controler for system administration."""

    def _stripAndDecode(self, rows):
        return [[column.strip().decode('utf-8') for column in row]
                for row in rows]

    def _getReader(self):
        file = request.POST.get('file_upload', None)
        if file is not None and file != '':
            return self._stripAndDecode(csv.reader(file.value.splitlines()))
        return []

    def _getLines(self):
        """CSV parser especially for logo import.

        We need to split the logo lines ourselves - csv reader is
        written in C and can't handle very very long lines.

        Only ids and logos are in the file, so we can assume no quoted
        cells in the csv file.
        """
        file = request.POST.get('file_upload', None)

        if file is not None and file != '':
            return self._stripAndDecode(
                [line.split(',')
                 for line in file.value.splitlines()])
        return []

    @ActionProtector("root")
    def index(self):
        return render('/admin/import.mako')

    @ActionProtector("root")
    def users(self):
        c.users = meta.Session.query(User).order_by(User.id).all()
        return render('/admin/users.mako')

    @ActionProtector("root")
    def import_users(self):
        for line in self._getReader():
            fullname = line[2]
            password = line[1][6:]
            email = line[3].lower()
            email = email_map.get(email, email)
            if not email:
                continue
            user = User.get(email)
            if user is None:
                user = User(fullname, password, False)
                email = Email(email)
                user.emails = [email]
                email.confirmed = True
                meta.Session.add(user)

            meta.Session.commit()
        redirect_to(controller='admin', action='users')

    @ActionProtector("root")
    def import_user_logos(self):
        for line in self._getLines():
            email = line[0]
            email = email_map.get(email, email)
            if not email:
                continue
            b64logo = line[1]
            user = User.get(email)
            if b64logo:
                user.logo = base64.b64decode(b64logo)
            else:
                user.logo = None
        meta.Session.commit()
        redirect_to(controller='admin', action='users')

    @ActionProtector("root")
    def import_structure(self):
        for line in self._getReader():
            title = line[1]
            title_short = line[0]
            description = line[2]
            parent = line[3]

            tag = LocationTag.get([parent, title_short])
            if tag is None:
                tag = LocationTag(title=title,
                                  title_short=title_short,
                                  description=description)
            tag.title = title
            tag.title_short = title_short
            tag.description = description

            meta.Session.add(tag)
            if parent:
                parent = LocationTag.get([parent])
                parent.children.append(tag)
            meta.Session.commit()
        redirect_to(controller='structure', action='index')

    @ActionProtector("root")
    def import_groups(self):
        for row in self._getReader():
            uni_id = row[5]
            fac_id = row[4]
            location = LocationTag.get([uni_id, fac_id])

            id, title, desc, year = row[:4]
            group = Group.get(id)
            if group is None:
                group = Group(group_id=id)
                meta.Session.add(group)

            group.title = title
            group.description = desc
            group.location = LocationTag.get([uni_id, fac_id])

            if year != '' and year != 'None':
                group.year = date(int(year), 1, 1)
            else:
                group.year = date(2008, 1, 1)

        meta.Session.commit()
        redirect_to(controller='group', action='index')

    @ActionProtector("root")
    def import_group_logos(self):
        for line in self._getLines():
            group_id = line[0]
            b64logo = line[1]
            group = Group.get(group_id)
            if b64logo:
                group.logo = base64.b64decode(b64logo)
            else:
                group.logo = None
        meta.Session.commit()
        redirect_to(controller='admin', action='users')

    @ActionProtector("root")
    def import_structure_logos(self):
        for line in self._getLines():
            tag_title = line[0].lower()
            parent_title = line[1].lower()
            b64logo = line[2]
            location_tag = LocationTag.get([parent_title, tag_title])
            if b64logo:
                location_tag.logo = base64.b64decode(b64logo)
            else:
                location_tag.logo = None
        meta.Session.commit()
        redirect_to(controller='admin', action='users')

    @ActionProtector("root")
    def import_subjects(self):
        for row in self._getReader():
            id, title, lecturer = row[:3]
            location_path = reversed(row[3:])
            location = LocationTag.get(location_path)
            title = title
            lecturer = lecturer
            subj = Subject.get(location, id)
            if subj is None:
                subj = Subject(id, title, location)
                meta.Session.add(subj)

            subj.title = title
            subj.lecturer = lecturer
        meta.Session.commit()
        redirect_to(controller='subject', action='index')

    @ActionProtector("root")
    def import_subjects_without_ids(self):
        for row in self._getReader():
            title, lecturer = row[:2]
            location_path = reversed(row[2:4])
            tags = filter(bool, [tag.strip() for tag in row[-1].split(',')])
            description = row[-2]
            id = ''.join(Random().sample(string.ascii_lowercase, 8)) # use random id first
            location = LocationTag.get(location_path)
            title = title
            lecturer = lecturer
            subj = Subject('', title, location)
            subj.lecturer = lecturer
            subj.description = description
            meta.Session.add(subj)
            meta.Session.flush()
            subj.subject_id = subj.generate_new_id()
            for tag in tags:
                subj.tags.append(SimpleTag.get(tag))
        meta.Session.commit()
        redirect_to(controller='subject', action='index')

    @ActionProtector("root")
    def import_group_members(self):
        #group membership types
        moderator = GroupMembershipType.get('administrator')
        member = GroupMembershipType.get('member')
        for row in self._getReader():
            group_id, email, is_moderator = row[:3]
            email = email_map.get(email, email)
            is_moderator = is_moderator == 'True'

            group = Group.get(group_id)
            user = User.get(email)

            membership = GroupMember()
            membership.role = is_moderator and moderator or member
            membership.user = user
            membership.group = group

            meta.Session.add(membership)
            meta.Session.commit()

        redirect_to(controller='group', action='index')

    @ActionProtector("root")
    def import_group_files(self):
        for line in self._getReader():
            author = User.get(line[-1])
            meta.Session.execute("SET ututi.active_user TO %d" % author.id)
            group_id = line[0]
            group = Group.get(group_id)
            f = File(filename=line[3], title=line[4])
            f.mimetype = line[2]
            f.folder = line[1]
            store_file(f, line[5])
            group.files.append(f)

        meta.Session.commit()
        redirect_to(controller='admin', action='index')

    @ActionProtector("root")
    def import_subject_files(self):
        for line in self._getReader():
            email = line[-1]
            email = email_map.get(email, email)
            author = User.get(email)
            meta.Session.execute("SET ututi.active_user TO %d" % author.id)
            subject_id = line[0]
            uni_id, fac_id = line[2], line[3]
            location = LocationTag.get([uni_id, fac_id])
            subject = Subject.get(location, subject_id)
            f = File(filename=line[5], title=line[6])
            f.mimetype = line[4]
            f.folder = line[1]
            store_file(f, line[7])
            subject.files.append(f)

        meta.Session.commit()
        redirect_to(controller='admin', action='index')

    @ActionProtector("root")
    def import_group_pages(self):
        for row in self._getReader():
            group_id, page_id, page_title, page_content, author_email = row

            if page_content not in (u'Welcome, please write something here!',
                                    u'Sveiki atvyk\u0119! Ra\u0161ykite \u010dia!',
                                    u'Sveiki, savo apra\u0161ym\u0105 ra\u0161ykite \u010dia.'):
                group = Group.get(group_id)
                group.page = page_content
                meta.Session.commit()

        redirect_to(controller='admin', action='index')

    @ActionProtector("root")
    def import_subject_pages(self):
        for row in self._getReader():
            subject_id, uni_id, fac_id, page_id, page_title, page_content, author_email = row

            location = LocationTag.get([uni_id, fac_id])
            subject = Subject.get(location, subject_id)
            author_email = email_map.get(author_email, author_email)
            author = User.get(author_email)
            meta.Session.execute("SET ututi.active_user TO %d" % author.id)
            subject.pages.append(Page(page_title,
                                      page_content))
        meta.Session.commit()
        redirect_to(controller='admin', action='index')

    @ActionProtector("root")
    def import_group_watched_subjects(self):
        for row in self._getReader():
            group = Group.get(row[0])
            location = LocationTag.get(row[1:3])
            subject = Subject.get(location, row[3])
            group.watched_subjects.append(subject)
        meta.Session.commit()
        redirect_to(controller='admin', action='index')

    @ActionProtector("root")
    def import_user_watched_subjects(self):
        for row in self._getReader():
            user = User.get(row[0])
            location = LocationTag.get(row[1:3])
            subject = Subject.get(location, row[3])

            usm = UserSubjectMonitoring(user, subject, ignored=False)
            meta.Session.add(usm)

        meta.Session.commit()
        redirect_to(controller='admin', action='index')

    @ActionProtector("root")
    def import_user_ignored_subjects(self):
        for row in self._getReader():
            user = User.get(row[0])
            location = LocationTag.get(row[1:3])
            subject = Subject.get(location, row[3])

            usm = UserSubjectMonitoring(user, subject, ignored=True)
            meta.Session.add(usm)

        meta.Session.commit()
        redirect_to(controller='admin', action='index')
