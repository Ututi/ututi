import csv
import logging
import base64

from magic import from_buffer
from datetime import date

from pylons import request, c
from pylons.controllers.util import redirect_to, abort

from ututi.lib.base import BaseController, render
from ututi.model import Page
from ututi.model import (meta, User, Email, LocationTag, Group, Subject,
                         GroupMember, GroupMembershipType, File)

log = logging.getLogger(__name__)

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

    def index(self):
        if c.user is None:
            abort(401, 'You are not authenticated')
        return render('/admin/import.mako')

    def users(self):
        if c.user is None:
            abort(401, 'You are not authenticated')

        c.users = meta.Session.query(User).all()
        return render('/admin/users.mako')

    def import_users(self):
        for line in self._getReader():
            fullname = line[2]
            password = line[1][6:]
            email = line[3].lower()
            user = User.get(email)
            if user is None:
                user = User(fullname, password, False)
                email = Email(email)
                user.emails = [email]
                email.confirmed = True
                meta.Session.add(user)

            meta.Session.commit()
        redirect_to(controller='admin', action='users')

    def import_user_logos(self):
        for line in self._getLines():
            email = line[0]
            b64logo = line[1]
            user = User.get(email)
            if b64logo:
                logo_content = base64.b64decode(b64logo)
                mime_type = from_buffer(logo_content, mime=True)
                logo = File("logo", "Avatar for %s" % user.fullname, mimetype=mime_type)
                logo.store(logo_content)
                meta.Session.add(logo)
                user.logo = logo
            else:
                user.logo = None
        meta.Session.commit()
        redirect_to(controller='admin', action='users')

    def import_structure(self):
        for line in self._getReader():
            title = line[1]
            title_short = line[0].lower()
            description = line[2]
            parent = line[3].lower()
            tag = LocationTag.get([parent, title_short])
            if tag is None:
                tag = LocationTag(title = title,
                                  title_short = title_short,
                                  description = description)
            tag.title = title
            tag.title_short = title_short
            tag.description = description

            meta.Session.add(tag)
            if parent:
                parent = LocationTag.get([parent])
                parent.children.append(tag)
            meta.Session.commit()
        redirect_to(controller='structure', action='index')

    def import_groups(self):
        for row in self._getReader():
            uni_id = row[5]
            fac_id = row[4]
            location = LocationTag.get([uni_id, fac_id])

            id, title, desc, year = row[:4]
            group = Group.get(id)
            if group is None:
                group = Group(id=id)
                meta.Session.add(group)

            group.title = title
            group.description = desc
            group.location = LocationTag.get([uni_id, fac_id])

            if year != '' and year != 'None':
                group.year = date(int(year), 1, 1)
            meta.Session.commit()
        redirect_to(controller='group', action='index')

    def import_group_logos(self):
        for line in self._getLines():
            group_id = line[0]
            b64logo = line[1]
            group = Group.get(group_id)
            if b64logo:
                logo_content = base64.b64decode(b64logo)
                mime_type = from_buffer(logo_content, mime=True)
                logo = File("logo", "Logo for group %s" % group.title,
                            mimetype=mime_type)
                logo.store(logo_content)
                meta.Session.add(logo)
                group.logo = logo
            else:
                group.logo = None
        meta.Session.commit()
        redirect_to(controller='admin', action='users')

    def import_structure_logos(self):
        for line in self._getLines():
            tag_title = line[0].lower()
            parent_title = line[1].lower()
            b64logo = line[2]
            location_tag = LocationTag.get([parent_title, tag_title])
            if b64logo:
                logo_content = base64.b64decode(b64logo)
                mime_type = from_buffer(logo_content, mime=True)
                logo = File("logo", "Logo for location tag %s" % location_tag.title,
                            mimetype=mime_type)
                logo.store(logo_content)
                meta.Session.add(logo)
                location_tag.logo = logo
            else:
                location_tag.logo = None
        meta.Session.commit()
        redirect_to(controller='admin', action='users')

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

    def import_group_members(self):
        #group membership types
        moderator = GroupMembershipType.get('administrator')
        member = GroupMembershipType.get('member')
        for row in self._getReader():
            group_id, email, is_moderator = row[:3]
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

    def import_group_files(self):
        for line in self._getReader():
            group_id = line[0]
            group = Group.get(group_id)
            f = File(filename=line[3], title=line[4])
            f.mimetype = line[2]
            f.folder = line[1]
            # XXX dummy content at the moment
            f.store('Whatever!')
            group.files.append(f)

            meta.Session.commit()
        redirect_to(controller='admin', action='users')

    def import_subject_files(self):
        for line in self._getReader():
            subject_id = line[0]
            uni_id, fac_id = line[2], line[3]
            location = LocationTag.get([uni_id, fac_id])
            subject = Subject.get(location, subject_id)
            f = File(filename=line[5], title=line[6])
            f.mimetype = line[4]
            f.folder = line[1]
            # XXX dummy content at the moment
            f.store('Whatever!')
            subject.files.append(f)

            meta.Session.commit()
        redirect_to(controller='admin', action='index')

    def import_group_pages(self):
        for row in self._getReader():
            group_id, page_id, page_title, page_content, author_email = row

            group = Group.get(group_id)
            author = User.get(author_email)
            group.pages.append(Page(page_title,
                                    page_content,
                                    author))
            meta.Session.commit()

        redirect_to(controller='admin', action='index')

    def import_subject_pages(self):
        for row in self._getReader():
            subject_id, uni_id, fac_id, page_id, page_title, page_content, author_email = row

            location = LocationTag.get([uni_id, fac_id])
            subject = Subject.get(location, subject_id)
            author = User.get(author_email)
            subject.pages.append(Page(page_title,
                                      page_content,
                                      author))
            meta.Session.commit()

        redirect_to(controller='admin', action='index')

    def import_group_watched_subjects(self):
        for row in self._getReader():
            group = Group.get(row[0])
            location = LocationTag.get(row[1:3])
            subject = Subject.get(location, row[3])
            group.watched_subjects.append(subject)
            meta.Session.commit()
        redirect_to(controller='admin', action='index')

    def import_user_watched_subjects(self):
        for row in self._getReader():
            user = User.get(row[0])
            location = LocationTag.get(row[1:3])
            subject = Subject.get(location, row[3])
            user.watched_subjects.append(subject)
        meta.Session.commit()
        redirect_to(controller='admin', action='index')

    def import_user_ignored_subjects(self):
        for row in self._getReader():
            user = User.get(row[0])
            location = LocationTag.get(row[1:3])
            subject = Subject.get(location, row[3])
            user.ignored_subjects.append(subject)
        meta.Session.commit()
        redirect_to(controller='admin', action='index')
