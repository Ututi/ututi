import csv
import string
import os
import logging
import base64
import datetime

from sqlalchemy.sql.expression import desc
from sqlalchemy.sql.expression import not_
from sqlalchemy import func
from magic import from_buffer
from datetime import date
from webhelpers import paginate

from babel.dates import parse_date
from babel.dates import format_date

from pylons import request, tmpl_context as c, config
from pylons.controllers.util import redirect_to, abort

from random import Random
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.model.events import Event
from ututi.model import FileDownload
from ututi.model import SimpleTag
from ututi.model import UserSubjectMonitoring
from ututi.model import Page
from ututi.model import (meta, User, Email, LocationTag, Group, Subject,
                         GroupMember, GroupMembershipType, File)
from ututi.lib import helpers as h


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
        return render('/admin/dashboard.mako')

    @ActionProtector("root")
    def import_csv(self):
        return render('/admin/import.mako')

    @ActionProtector("root")
    def users(self):
        locale = config.get('locale')
        c.from_time_str = request.params.get('from_time')
        if not c.from_time_str:
            c.from_time_str = format_date(datetime.date.today() - datetime.timedelta(7),
                                          format="short",
                                          locale=locale)
        c.to_time_str = request.params.get('to_time')
        if not c.to_time_str:
            c.to_time_str = format_date(datetime.date.today() + datetime.timedelta(1),
                                        format="short",
                                        locale=locale)
        from_time = parse_date(c.from_time_str, locale=locale)
        to_time = parse_date(c.to_time_str, locale=locale)

        pages_stmt = meta.Session.query(
            Event.author_id,
            func.count(Event.created).label('pages_count'))\
            .filter(Event.event_type == 'page_created')\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .group_by(Event.author_id).subquery()

        uploads_stmt = meta.Session.query(
            Event.author_id,
            func.count(Event.created).label('uploads_count'))\
            .filter(Event.event_type == 'file_uploaded')\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .group_by(Event.author_id).subquery()

        messages_stmt = meta.Session.query(
            Event.author_id,
            func.count(Event.created).label('messages_count'))\
            .filter(Event.event_type == 'forum_post_created')\
            .filter(Event.created < to_time)\
            .filter(Event.created >= from_time)\
            .group_by(Event.author_id).subquery()

        downloads_stmt = meta.Session.query(
            FileDownload.user_id,
            func.count(FileDownload.file_id).label('downloads_count'),
            func.count(func.distinct(FileDownload.file_id)).label('unique_downloads_count'),
            func.sum(File.filesize).label('downloads_size'))\
            .filter(FileDownload.download_time < to_time)\
            .filter(FileDownload.download_time >= from_time)\
            .outerjoin((File, File.id == FileDownload.file_id))\
            .group_by(FileDownload.user_id).subquery()


        users = meta.Session.query(User,
                                   func.coalesce(downloads_stmt.c.downloads_count, 0).label('downloads'),
                                   func.coalesce(downloads_stmt.c.unique_downloads_count, 0).label('unique_downloads'),
                                   func.coalesce(downloads_stmt.c.downloads_size, 0).label('downloads_size'),
                                   func.coalesce(uploads_stmt.c.uploads_count, 0).label('uploads'),
                                   func.coalesce(messages_stmt.c.messages_count, 0).label('messages'),
                                   func.coalesce(pages_stmt.c.pages_count, 0).label('pages'))\
            .outerjoin((downloads_stmt, downloads_stmt.c.user_id == User.id))\
            .outerjoin((uploads_stmt, uploads_stmt.c.author_id == User.id))\
            .outerjoin((messages_stmt, messages_stmt.c.author_id == User.id))\
            .outerjoin((pages_stmt, pages_stmt.c.author_id == User.id))

        order_by = request.params.get('order_by', 'id')
        if order_by == 'id':
            users = users.order_by(desc(User.id))
        else:
            users = users.order_by(desc(order_by))

        c.users = paginate.Page(
            users,
            page=int(request.params.get('page', 1)),
            item_count=users.count() or 0,
            items_per_page=100,
            order_by=order_by,
            from_time=c.from_time_str,
            to_time=c.to_time_str)
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
        redirect_to(controller='admin', action='groups')

    @ActionProtector("root")
    def import_subjects_without_ids(self):
        for row in self._getReader():
            title, lecturer = row[:2]
            location_path = reversed(row[2:4])
            tags = filter(bool, [tag.strip() for tag in row[5].split(',')])
            description = row[-2]
            id = ''.join(Random().sample(string.ascii_lowercase, 8)) # use random id first
            location = LocationTag.get(location_path)

            #do not import duplicates
            existing = meta.Session.query(Subject).filter(Subject.location_id == location.id).filter(func.upper(Subject.title) == func.upper(title)).first()
            if existing:
                log.info('Subject exists: %s' % row)
                h.flash('Subject exists: %s' % row)
                continue

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
        redirect_to(controller='admin', action='subjects')

    @ActionProtector('root')
    def files(self):

        files = meta.Session.query(File)\
            .order_by(desc(File.created_on))\
            .filter(File.title != u'text.html')\
            .filter(File.title != u'Null File')\
            .filter(File.deleted_on == None)

        c.files = self._make_pages(files)

        return render('admin/files.mako')

    @ActionProtector('root')
    def deleted_files(self):
        files = meta.Session.query(File)\
            .order_by(desc(File.deleted_on))\
            .filter(File.title != u'text.html')\
            .filter(File.title != u'Null File')\
            .filter(File.deleted_on != None)

        c.files = self._make_pages(files)

        return render('admin/deleted_files.mako')


    @ActionProtector("root")
    def groups(self):
        c.groups = meta.Session.query(Group).order_by(Group.created_on).all()
        return render('admin/groups.mako')

    @ActionProtector("root")
    def subjects(self):
        subjects = meta.Session.query(Subject)\
            .order_by(desc(Subject.created_on))
        c.subjects = self._make_pages(subjects)
        return render('admin/subjects.mako')

    @ActionProtector("root")
    def events(self):
        events = meta.Session.query(Event)\
            .order_by(desc(Event.created))
        c.events = self._make_pages(events)
        return render('admin/events.mako')

    def _make_pages(self, items):
        return paginate.Page(items,
                             page=int(request.params.get('page', 1)),
                             item_count=items.count() or 0,
                             items_per_page=100)

    def error(self):
        return 1 / 0
