# -*- encoding: utf-8 -*-
import logging
import datetime

from pylons.controllers.util import redirect

from sqlalchemy.sql.expression import or_
from sqlalchemy.sql.expression import desc
from sqlalchemy import func
from webhelpers import paginate
from formencode import htmlfill
from formencode.compound import Any, Pipe
from formencode.schema import Schema
from formencode.validators import Int
from formencode.validators import Constant
from formencode.validators import DateConverter
from formencode.validators import OneOf
from formencode.validators import String
from formencode.validators import Regex

from babel.dates import parse_date
from babel.dates import format_date

from pylons import request, tmpl_context as c, url

from ututi.lib.security import sign_in_admin_user, sign_out_admin_user

from ututi.lib.wall import WallMixin

from ututi.lib.security import ActionProtector
from ututi.lib.base import BaseController, render
from ututi.lib.validators import PhoneNumberValidator, validate, \
    LanguageIdValidator, LanguageValidator, SeparatedListValidator
from ututi.lib.emails import teacher_confirmed_email
from ututi.model.users import AdminUser
from ututi.model.events import Event
from ututi.model import FileDownload
from ututi.model import (meta, User, Email, Group, Subject,
                         File, PrivateMessage, Teacher, LocationTag)
from ututi.model import Notification
from ututi.model import EmailDomain
from ututi.model.i18n import Language, LanguageText
from ututi.controllers.admin.export import UniversityExportMixin

from ututi.lib import helpers as h


log = logging.getLogger(__name__)


class NotificationForm(Schema):
    allow_extra_fields = True
    valid_until = DateConverter(not_empty=True)
    content = String(min=1)


class TeacherSearchForm(Schema):
    allow_extra_fields = True
    user_id = Int(not_empty=False)
    user_name = String(not_empty=False)


class LanguageAddForm(Schema):
    id = LanguageIdValidator()
    title = String(min=1, max=100, not_empty=True)


class LanguageEditForm(Schema):
    id = String(min=1, max=100, not_empty=True)
    title = String(min=1, max=100, not_empty=True)


class LanguageTextForm(Schema):
    id = String(min=1, max=100, not_empty=True)
    language = LanguageValidator()
    i18n_text = String(not_empty=True)


class EmailDomainsForm(Schema):
    location_id = Int()
    domains = Pipe(String(),
                   SeparatedListValidator(separators=','))


class AdminController(BaseController, UniversityExportMixin, WallMixin):
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
            else:
                h.flash("Access denied!")
        return render('admin/login.mako')

    @ActionProtector("root")
    def logout(self):
        sign_out_admin_user()
        redirect(url('frontpage'))

    def _stripAndDecode(self, rows):
        return [[column.strip().decode('utf-8') for column in row]
                for row in rows]

    @ActionProtector("root")
    def index(self):
        return render('/admin/dashboard.mako')

    @ActionProtector("root")
    def users(self):
        locale = c.locale
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

    @ActionProtector("root")
    def admin_wall(self):
        self._set_wall_variables(limit=200)
        return render('admin/feed.mako')

    def _wall_events_query(self):
        """WallMixin implementation."""
        from ututi.lib.wall import generic_events_query
        evts_generic = generic_events_query()

        return evts_generic

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
            teacher.confirm()
            meta.Session.commit()
            teacher_confirmed_email(teacher, True)
            h.flash('Teacher confirmed.')
        else:
            teacher.revert_to_user()
            teacher_confirmed_email(teacher, False)
            h.flash('Teacher rejected.')

        redirect(url(controller="admin", action="teachers"))

    @ActionProtector("root")
    def teacher_convert(self, id):
        teacher = meta.Session.query(User).filter(User.id == id).one()

        authors_table = meta.metadata.tables['authors']
        teachers_table = meta.metadata.tables['teachers']
        # a hack: cannot update a polymorphic descriptor column using the orm (rejecting a teacher is basically converting him into a user)
        conn = meta.engine.connect()
        upd = authors_table.update().where(authors_table.c.id==id).values(type='teacher')
        ins = teachers_table.insert().values(id=id, teacher_verified=True, teacher_position=None)

        teacher_confirmed_email(teacher, True)
        conn.execute(upd)
        conn.execute(ins)
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

    @ActionProtector("root")
    def example_layouts(self):
        return render('sections/example_layouts.mako')

    @ActionProtector("root")
    def languages(self):
        c.languages = meta.Session.query(Language).order_by(Language.title.asc()).all()
        return render('admin/languages.mako')

    @ActionProtector("root")
    @validate(schema=LanguageAddForm, form='languages')
    def add_language(self):
        if hasattr(self, 'form_result'):
            language = Language(id=self.form_result['id'],
                                title=self.form_result['title'])
            meta.Session.add(language)
            meta.Session.commit()
        redirect(url(controller='admin', action='languages'))

    @ActionProtector("root")
    def _edit_language_form(self):
        return render('admin/language_edit.mako')

    @ActionProtector("root")
    def edit_language(self, id):
        c.language  = Language.get(id)
        defaults = {
            'id': c.language.id,
            'title': c.language.title
        }
        return htmlfill.render(self._edit_language_form(), defaults)

    @ActionProtector("root")
    def delete_language(self, id):
        c.language  = Language.get(id)
        meta.Session.delete(c.language)
        meta.Session.commit()
        redirect(url(controller='admin', action='languages'))

    @ActionProtector("root")
    @validate(schema=LanguageEditForm, form='_edit_language_form')
    def update_language(self):
        if hasattr(self, 'form_result'):
            language = Language.get(self.form_result['id'])
            language.title = self.form_result['title']
            meta.Session.commit()
        redirect(url(controller='admin', action='languages'))

    @ActionProtector("root")
    def i18n_texts(self):
        c.texts = meta.Session.query(LanguageText).\
                order_by(LanguageText.id.asc(),
                         LanguageText.language_id.asc()).all()
        return render('admin/i18n_texts.mako')

    @ActionProtector("root")
    @validate(schema=LanguageTextForm, form='languages')
    def add_i18n_text(self):
        if hasattr(self, 'form_result'):
            text = LanguageText(self.form_result['id'],
                                self.form_result['language'],
                                self.form_result['i18n_text'])
            meta.Session.add(text)
            meta.Session.commit()
        redirect(url(controller='admin', action='i18n_texts'))

    @ActionProtector("root")
    def _edit_i18n_text_form(self):
        return render('admin/i18n_text_edit.mako')

    @ActionProtector("root")
    def edit_i18n_text(self, id, lang):
        c.text = LanguageText.get(id, lang)
        defaults = {
            'id': c.text.id,
            'language': c.text.language_id,
            'i18n_text': c.text.text
        }
        return htmlfill.render(self._edit_i18n_text_form(), defaults)

    @ActionProtector("root")
    @validate(schema=LanguageTextForm, form='_edit_language_form')
    def update_i18n_text(self):
        if hasattr(self, 'form_result'):
            id = self.form_result['id']
            lang = self.form_result['language']
            text = LanguageText.get(id, lang)
            text.text = self.form_result['i18n_text']
            meta.Session.commit()
        redirect(url(controller='admin', action='i18n_texts'))

    @ActionProtector("root")
    @validate(schema=EmailDomainsForm, form='public_email_domains')
    def email_domains(self):
        if hasattr(self, 'form_result'):
            location_id = self.form_result.get('location_id', 0)
            location = LocationTag.get(location_id)
            # here location_id = 0 -> location = None -> domain is public
            for domain in self.form_result['domains']:
                meta.Session.add(EmailDomain(domain, location))
            meta.Session.commit()

        unis = meta.Session.query(LocationTag)\
            .filter(LocationTag.parent == None)\
            .order_by(LocationTag.title.asc())
        c.uni_options = [(0, 'Public domain')]
        for uni in unis:
            for u in uni.flatten:
                title = u.title
                if u.parent:
                    title = "%s: %s" % (u.parent.title, u.title)
                c.uni_options.append((u.id, title))

        c.public_domains = EmailDomain.all()
        return render('admin/email_domains.mako')

    @ActionProtector("root")
    def delete_email_domain(self, id):
        domain = EmailDomain.get(id)
        if domain is not None:
            domain.delete()
            meta.Session.commit()
        else:
            h.flash('Email domain with id %s does not exist' % id)
        redirect(url(controller='admin', action='email_domains'))
