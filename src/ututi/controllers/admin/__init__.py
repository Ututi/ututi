# -*- encoding: utf-8 -*-
import csv
import os
import logging
import datetime

from pylons.controllers.util import redirect

from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import desc
from sqlalchemy import func
from datetime import date
from webhelpers import paginate
from formencode import htmlfill
from formencode.compound import Any
from formencode.schema import Schema
from formencode.validators import Int
from formencode.validators import Constant
from formencode.validators import DateConverter
from formencode.validators import OneOf
from formencode.validators import String
from formencode.validators import Regex

from babel.dates import parse_date
from babel.dates import format_date

from pylons import request, tmpl_context as c, config, url

from ututi.lib.security import sign_in_admin_user
from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.lib.validators import PhoneNumberValidator, GroupCouponValidator, validate
from ututi.lib.emails import teacher_confirmed_email
from ututi.model.users import AdminUser
from ututi.model.events import Event
from ututi.model import Department
from ututi.model import Region
from ututi.model import FileDownload
from ututi.model import SimpleTag
from ututi.model import SMS, GroupCoupon
from ututi.model import (meta, User, Email, LocationTag, Group, Subject,
                         File, PrivateMessage, Teacher)
from ututi.model import Notification, City, ScienceType, SchoolGrade, BookType
from ututi.controllers.admin.export import UniversityExportMixin
from ututi.controllers.books import BookDepartmentValidator

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


class SMSForm(Schema):
    allow_extra_fields = False
    number = PhoneNumberValidator()
    message = String(min=1, max=130)


class GroupCouponForm(Schema):
    allow_extra_fields = False
    code = GroupCouponValidator(check_collision=True)
    action = OneOf(['smscredits', 'unlimitedspace'])
    day_count = Any(Constant(''), Int(min=0))
    valid_until = DateConverter()


class NotificationForm(Schema):
    allow_extra_fields = True
    valid_until = DateConverter(not_empty=True)
    content = String(min=1)


class TeacherSearchForm(Schema):
    allow_extra_fields = True
    user_id = Int(not_empty=False)
    user_name = String(not_empty=False)


class CityForm(Schema):
    allow_extra_fields = True
    name = String(min=1)


class SchoolGradeForm(Schema):
    allow_extra_fields = True
    name = String(min=1)


class ScienceTypeForm(Schema):
    allow_extra_fields = True
    name = String(min=3)
    department = BookDepartmentValidator(not_empty=True)


class BookTypeForm(Schema):
    allow_extra_fields = True
    name = String(min=1)
    url_name = Regex(r'^[a-z-]+$', not_empty=True)


class AdminController(BaseController, UniversityExportMixin):
    """Controler for system administration."""

    def login(self):
        return render('admin/login.mako')

    def join_login(self):
        email = request.POST.get('login_username')
        password = request.POST.get('login_password')
        if password is not None:
            admin_user = AdminUser.authenticate(email, password.encode('utf-8'))
            if admin_user:
                sign_in_admin_user(admin_user)
                redirect(url(controller='admin', action='index'))
        return render('admin/login.mako')

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
            .filter(Event.event_type == 'mailinglist_post_created')\
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
            .filter(FileDownload.range_start==None)\
            .filter(FileDownload.range_end==None)\
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
        redirect(url(controller='admin', action='users'))

    @ActionProtector("root")
    def import_group_members(self):
        for line in self._getReader():
            group_id = line[0]
            user_id = line[1].lower()
            user_id = email_map.get(user_id, user_id)
            is_admin = line[2] == u'True'

            user = User.get(user_id)
            group = Group.get(group_id)
            if group is not None and user is not None:
                group.add_member(user, is_admin)

            meta.Session.commit()
        redirect(url(controller='admin', action='import_csv'))

    @ActionProtector("root")
    def import_structure(self):
        for line in self._getReader():
            title_short = line[0]
            title = line[1]
            description = line[2]
            parent = line[3]
            region_title = line[4]
            site_url = line[5]

            tag = LocationTag.get([parent, title_short])
            if tag is None:
                tag = LocationTag(title=title,
                                  title_short=title_short,
                                  description=description)
            tag.title = title
            tag.title_short = title_short
            tag.description = description
            tag.site_url = site_url
            if region_title:
                tag.region = meta.Session.query(Region).filter_by(title=region_title).one()

            meta.Session.add(tag)
            if parent:
                parent = LocationTag.get([parent])
                parent.children.append(tag)
            meta.Session.commit()
        redirect(url(controller='structure', action='index'))

    @ActionProtector("root")
    def import_groups(self):
        for row in self._getReader():
            uni_id = row[5]
            fac_id = row[4]

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
        redirect(url(controller='admin', action='groups'))

    @ActionProtector("root")
    def import_subjects_without_ids(self):
        for row in self._getReader():
            title, lecturer = row[:2]
            location_path = reversed(row[2:4])
            tags = filter(bool, [tag.strip() for tag in row[5].split(',')])
            description = row[-2]
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
        redirect(url(controller='admin', action='subjects'))

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
    def sms(self):
        messages = meta.Session.query(SMS)\
            .order_by(SMS.created.desc())

        c.messages = self._make_pages(messages)
        return render('admin/sms.mako')

    @ActionProtector('root')
    @validate(schema=SMSForm, form='sms')
    def send_sms(self):
        if hasattr(self, 'form_result'):
            msg = SMS(sender=c.user,
                      recipient_number=self.form_result.get('number'),
                      message_text=self.form_result.get('message'))
            meta.Session.add(msg)
            meta.Session.commit()
            h.flash('Message sent to number %s' % self.form_result.get('number'))
        redirect(url(controller='admin', action='sms'))

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
        groups = meta.Session.query(Group).order_by(desc(Group.id)).all()
        order_by = request.params.get('order_by', 'id')

        c.groups = paginate.Page(
            groups,
            page=int(request.params.get('page', 1)),
            item_count=len(groups) or 0,
            items_per_page=100,
            order_by=order_by,
            )
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

    @ActionProtector("root")
    def messages(self):
        if 'message' in request.params:
            title = request.params.get('title')
            message = request.params.get('message')
            users = meta.Session.query(User).all()
            for recipient in users:
                msg = PrivateMessage(c.user, recipient, title, message)
                msg.hidden_by_sender = True
            meta.Session.commit()
            h.flash('Message sent to %d users.' % len(users))
        return render('admin/messages.mako')


    @ActionProtector("root")
    @validate(schema=GroupCouponForm, form='group_coupons')
    def group_coupons(self):
        groupcoupons = meta.Session.query(GroupCoupon).order_by(GroupCoupon.valid_until.desc()).order_by(GroupCoupon.created.desc())
        c.groupcoupons = self._make_pages(groupcoupons)
        return render('admin/groupcoupons.mako')

    @ActionProtector("root")
    @validate(schema=GroupCouponForm, form='group_coupons')
    def add_coupon(self):
        if hasattr(self, 'form_result'):
            coupon = GroupCoupon(code=self.form_result['code'],
                                 valid_until=self.form_result['valid_until'],
                                 action=self.form_result['action'])
            if coupon.action == 'smscredits':
                coupon.credit_count = self.form_result['credit_count']
            elif coupon.action == 'unlimitedspace':
                coupon.day_count = self.form_result['day_count']
            meta.Session.add(coupon)
            meta.Session.commit()
        redirect(url(controller='admin', action='group_coupons'))

    @ActionProtector("root")
    def notifications(self):
        notifications = meta.Session.query(Notification).order_by(Notification.id.asc())
        c.notifications = self._make_pages(notifications)
        return render('admin/notifications.mako')

    @ActionProtector("root")
    @validate(schema=NotificationForm, form='notifications')
    def add_notification(self):
        if hasattr(self, 'form_result'):
            notification = Notification(content=self.form_result['content'],
                                 valid_until=self.form_result['valid_until'])
            meta.Session.add(notification)
            meta.Session.commit()
        redirect(url(controller='admin', action='notifications'))

    @ActionProtector("root")
    def _edit_notification_form(self):
        return render('admin/notification_edit.mako')

    @ActionProtector("root")
    def edit_notification(self, id):
        c.notification = meta.Session.query(Notification).filter(Notification.id == id).one()
        defaults = {
            'id': c.notification.id,
            'content': c.notification.content,
            'valid_until': c.notification.valid_until.strftime('%m/%d/%Y') }
        return htmlfill.render(self._edit_notification_form(), defaults)

    @ActionProtector("root")
    @validate(schema=NotificationForm, form='_edit_notification_form')
    def update_notification(self):
        if hasattr(self, 'form_result'):
            id = self.form_result['id']
            notification = meta.Session.query(Notification).filter(Notification.id == id).one()
            notification.content = self.form_result['content']
            notification.valid_until = self.form_result['valid_until']
            meta.Session.commit()
        redirect(url(controller='admin', action='notifications'))

    @ActionProtector("root")
    def cities(self):
        cities = meta.Session.query(City).order_by(City.name.asc())
        c.cities = self._make_pages(cities)
        return render('admin/cities.mako')

    @ActionProtector("root")
    @validate(schema=CityForm, form='cities')
    def create_city(self):
        if hasattr(self, 'form_result'):
            city = City(name=self.form_result['name'])
            meta.Session.add(city)
            meta.Session.commit()
        redirect(url(controller="admin", action="cities"))

    @ActionProtector("root")
    def _edit_city_form(self):
        return render('admin/city_edit.mako')

    @ActionProtector("root")
    def edit_city(self, id):
        c.city = meta.Session.query(City).filter(City.id == id).one()
        defaults = {
            'id': c.city.id,
            'name': c.city.name}
        return htmlfill.render(self._edit_city_form(), defaults)

    @ActionProtector("root")
    @validate(schema=CityForm, form='_edit_city_form')
    def update_city(self, id):
        city = meta.Session.query(City).filter(City.id == id).one()
        if hasattr(self, 'form_result'):
            city.name = self.form_result['name']
            meta.Session.commit()
        redirect(url(controller="admin", action="cities"))

    @ActionProtector("root")
    def delete_city(self, id):
        city = meta.Session.query(City).filter(City.id == id).one()
        meta.Session.delete(city)
        meta.Session.commit()
        redirect(url(controller="admin", action="cities"))

    @ActionProtector("root")
    def school_grades(self):
        school_grade = meta.Session.query(SchoolGrade).order_by(SchoolGrade.id.asc())
        c.school_grades = self._make_pages(school_grade)
        return render('admin/school_grades.mako')

    @ActionProtector("root")
    def _edit_school_grade_form(self):
        return render('admin/school_grade_edit.mako')


    @ActionProtector("root")
    def edit_school_grade(self, id):
        c.school_grade = meta.Session.query(SchoolGrade).filter(SchoolGrade.id == id).one()
        defaults = {'id': c.school_grade.id,
                    'name': c.school_grade.name}
        return htmlfill.render(self._edit_school_grade_form(), defaults)

    @ActionProtector("root")
    @validate(schema=SchoolGradeForm, form='school_grade')
    def update_school_grade(self, id):
        school_grade = meta.Session.query(SchoolGrade).filter(SchoolGrade.id == id).one()
        if hasattr(self, 'form_result'):
            school_grade.name = self.form_result['name']
            meta.Session.commit()
        redirect(url(controller="admin", action="school_grades"))

    @ActionProtector("root")
    def delete_school_grade(self, id):
        school_grade = meta.Session.query(SchoolGrade).filter(SchoolGrade.id == id).one()
        meta.Session.delete(school_grade)
        meta.Session.commit()
        redirect(url(controller="admin", action="school_grades"))


    @ActionProtector("root")
    @validate(schema=SchoolGradeForm, form='school_grade')
    def create_school_grade(self):
        if hasattr(self, 'form_result'):
            school_grade = SchoolGrade(name=self.form_result['name'])
            meta.Session.add(school_grade)
            meta.Session.commit()
        redirect(url(controller="admin", action="school_grades"))

    def science_types(self):
        science_types = meta.Session.query(ScienceType).order_by(ScienceType.book_department_id.asc(), ScienceType.name.asc())
        c.book_departments = [('', '')] + [(d.name, d.title) for d in Department.values()]
        c.science_types = self._make_pages(science_types)
        return render('admin/science_types.mako')

    @ActionProtector("root")
    @validate(schema=ScienceTypeForm, form='science_types')
    def create_science_type(self):
        if hasattr(self, 'form_result'):
            science_type = ScienceType(name=self.form_result['name'], book_department_id=self.form_result['department'].id)
            meta.Session.add(science_type)
            meta.Session.commit()
        redirect(url(controller="admin", action="science_types"))

    @ActionProtector("root")
    def _edit_science_type_form(self):
        c.book_departments = [(d.name, d.title) for d in Department.values()]
        return render('admin/science_type_edit.mako')

    @ActionProtector("root")
    def edit_science_type(self, id):
        c.science_type = meta.Session.query(ScienceType).filter(ScienceType.id == id).one()
        defaults = {
            'id': c.science_type.id,
            'name': c.science_type.name,
            'department': Department.get(c.science_type.book_department_id).name}
        return htmlfill.render(self._edit_science_type_form(), defaults)

    @ActionProtector("root")
    @validate(schema=ScienceTypeForm, form='_edit_science_type_form')
    def update_science_type(self, id):
        science_type = meta.Session.query(ScienceType).filter(ScienceType.id == id).one()
        if hasattr(self, 'form_result'):
            science_type.name = self.form_result['name']
            science_type.book_department_id = self.form_result['department'].id
            meta.Session.commit()
        redirect(url(controller="admin", action="science_types"))

    @ActionProtector("root")
    def delete_science_type(self, id):
        science_type = meta.Session.query(ScienceType).filter(ScienceType.id == id).one()
        meta.Session.delete(science_type)
        meta.Session.commit()
        redirect(url(controller="admin", action="science_types"))

    @ActionProtector("root")
    def book_types(self):
        book_types = meta.Session.query(BookType).order_by(BookType.name.asc())
        c.book_types = self._make_pages(book_types)
        return render('admin/book_types.mako')

    @ActionProtector("root")
    @validate(schema=BookTypeForm, form='book_types')
    def create_book_type(self):
        if hasattr(self, 'form_result'):
            book_type = BookType(name=self.form_result['name'],
                                 url_name=self.form_result['url_name'])
            meta.Session.add(book_type)
            meta.Session.commit()
        redirect(url(controller="admin", action="book_types"))

    @ActionProtector("root")
    def _edit_book_type_form(self):
        return render('admin/book_type_edit.mako')

    @ActionProtector("root")
    def edit_book_type(self, id):
        c.book_type = meta.Session.query(BookType).filter(BookType.id == id).one()
        defaults = {
            'id': c.book_type.id,
            'name': c.book_type.name,
            'url_name': c.book_type.url_name}
        return htmlfill.render(self._edit_book_type_form(), defaults)

    @ActionProtector("root")
    @validate(schema=BookTypeForm, form='_edit_book_type_form')
    def update_book_type(self, id):
        book_type = meta.Session.query(BookType).filter(BookType.id == id).one()
        if hasattr(self, 'form_result'):
            book_type.name = self.form_result['name']
            book_type.url_name = self.form_result['url_name']
            meta.Session.commit()
        redirect(url(controller="admin", action="book_types"))

    @ActionProtector("root")
    def delete_book_type(self, id):
        book_type = meta.Session.query(BookType).filter(BookType.id == id).one()
        meta.Session.delete(book_type)
        meta.Session.commit()
        redirect(url(controller="admin", action="book_types"))

    @ActionProtector("root")
    @validate(schema=TeacherSearchForm, form='teachers')
    def teachers(self):
        c.teachers = meta.Session.query(Teacher).filter(Teacher.teacher_verified == False).all()
        user_id = request.params.get('user_id', None)
        user_name = None
        if hasattr(self, 'form_result'):
            user_id = self.form_result.get('user_id', user_id)
            user_name = self.form_result.get('user_name', None)
        c.found_users = []
        if user_id is not None or user_name is not None:
            users = meta.Session.query(User).join(Email)
            if user_id is not None:
                users = users.filter(User.id == user_id)
            elif user_name is not None:
                users = users.filter(or_(User.fullname.ilike('%%%s%%' % user_name),
                                         Email.email.ilike('%%%s%%' % user_name)))
            c.found_users = users.all()
        return render('admin/teachers.mako')

    @ActionProtector("root")
    def teacher_status(self, command, id):
        teacher = meta.Session.query(Teacher).filter(Teacher.id == id).filter(Teacher.teacher_verified==False).one()
        if command == 'confirm':
            teacher.teacher_verified = True
            meta.Session.commit()
            teacher_confirmed_email(teacher, True)
            h.flash('Teacher confirmed.')
        else:
            from ututi.model import users_table
            # a hack: cannot update a polymorphic descriptor column using the orm (rejecting a teacher is basically converting him into a user)
            conn = meta.engine.connect()
            upd = users_table.update().where(users_table.c.id==id).values(user_type='user', teacher_verified=None, teacher_position=None)
            teacher_confirmed_email(teacher, False)
            conn.execute(upd)
            h.flash('Teacher rejected.')

        redirect(url(controller="admin", action="teachers"))

    @ActionProtector("root")
    def teacher_convert(self, id):
        teacher = meta.Session.query(User).filter(User.id == id).one()

        from ututi.model import users_table
        # a hack: cannot update a polymorphic descriptor column using the orm (rejecting a teacher is basically converting him into a user)
        conn = meta.engine.connect()
        upd = users_table.update().where(users_table.c.id==id).values(user_type='teacher', teacher_verified=True, teacher_position=None)
        teacher_confirmed_email(teacher, True)
        conn.execute(upd)
        h.flash('User is now a teacher.')

        redirect(url(controller="admin", action="teachers"))

    @ActionProtector("root")
    def example_blocks(self):
        return render('sections/example_blocks.mako')

    @ActionProtector("root")
    def example_lists(self):
        c.example_subjects = meta.Session.query(Subject).limit(5)
        return render('sections/example_lists.mako')

    @ActionProtector("root")
    def example_objects(self):
        c.subject = meta.Session.query(Subject).first()
        c.group = meta.Session.query(Group).first()
        return render('sections/example_objects.mako')

    @ActionProtector("root")
    def example_widgets(self):
        return render('sections/example_widgets.mako')
