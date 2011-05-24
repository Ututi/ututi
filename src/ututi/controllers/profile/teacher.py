from formencode import htmlfill

from pylons import tmpl_context as c, url
from pylons.controllers.util import abort, redirect

from pylons.i18n import _

import ututi.lib.helpers as h
from ututi.lib.base import render
from ututi.lib.security import ActionProtector
from ututi.lib.forms import validate
from ututi.lib.messaging import EmailMessage
from ututi.lib.mailinglist import post_message

from ututi.model import meta, File, TeacherGroup
from ututi.model.events import TeacherMessageEvent
from ututi.controllers.profile.base import ProfileControllerBase
from ututi.controllers.profile.validators import BiographyForm, \
        StudentGroupForm, StudentGroupDeleteForm, StudentGroupMessageForm, \
        PublicationsForm

def group_teacher_action(method):
    def _group_teacher_action(self, id=None):
        if id is None:
            redirect(url(controller='search', action='index'))
        group = TeacherGroup.get(id)
        if group is None:
            abort(404)
        c.security_context = group
        c.group = group
        return method(self, group)
    return _group_teacher_action


class TeacherProfileController(ProfileControllerBase):

    @ActionProtector("teacher")
    def home(self):
        redirect(url(controller='profile', action='dashboard'))

    @ActionProtector("teacher")
    def register_welcome(self):
        c.welcome = True
        return render('/profile/teacher/dashboard.mako')

    @ActionProtector("teacher")
    def dashboard(self):
        return render('/profile/teacher/dashboard.mako')

    def _edit_profile_tabs(self):
        tabs = ProfileControllerBase._edit_profile_tabs(self)
        tabs.extend([
            {'title': _("Biography"),
             'name': 'biography',
             'link': url(controller='profile', action='edit_biography')},
            {'title': _("Publications"),
             'name': 'publications',
             'link': url(controller='profile', action='edit_publications')},
        ])
        return tabs

    def _edit_biography_form(self):
        c.tabs = self._edit_profile_tabs()
        c.current_tab = 'biography'
        return render('profile/teacher/edit_biography.mako')

    @ActionProtector("user")
    def edit_biography(self):
        if c.user.description and c.user.description.strip():
            # description is not empty
            defaults = {'description': c.user.description}
        else:
            template = render('profile/teacher/biography_template.mako')
            defaults = {'description': template}
            c.edit_template = True
        return htmlfill.render(self._edit_biography_form(), defaults=defaults)

    @validate(schema=BiographyForm, form='_edit_biography_form')
    @ActionProtector("user")
    def update_biography(self):
        if not hasattr(self, 'form_result'):
            redirect(url(controller='profile', action='edit_biography'))

        c.user.description = self.form_result['description']
        meta.Session.commit()
        h.flash(_('Your biography was updated.'))

        redirect(url(controller='profile', action='edit_biography'))

    def _edit_publications_form(self):
        c.tabs = self._edit_profile_tabs()
        c.current_tab = 'publications'
        return render('profile/teacher/edit_publications.mako')

    @ActionProtector("user")
    def edit_publications(self):
        if c.user.publications and c.user.publications.strip():
            # publication field is not empty
            defaults = {'publications': c.user.publications}
        else:
            template = render('profile/teacher/publications_template.mako')
            defaults = {'publications': template}
            c.edit_template = True
        return htmlfill.render(self._edit_publications_form(), defaults=defaults)

    @validate(schema=PublicationsForm, form='_edit_publications_form')
    @ActionProtector("user")
    def update_publications(self):
        if not hasattr(self, 'form_result'):
            redirect(url(controller='profile', action='edit_publications'))

        c.user.publications = self.form_result['publications']
        meta.Session.commit()
        h.flash(_('Your publication page was updated.'))

        redirect(url(controller='profile', action='edit_publications'))

    @ActionProtector("teacher")
    @validate(schema=StudentGroupForm, form='add_student_group', on_get=False)
    def add_student_group(self):
        if hasattr(self, 'form_result'):
            group = TeacherGroup(self.form_result['title'],
                                 self.form_result['email'])
            c.user.student_groups.append(group)
            meta.Session.commit()
            message = _(u'Group %(group_title)s (%(group_email)s) added!') % {
                'group_title': group.title,
                'group_email': group.email}
            h.flash(message)
            redirect(url(controller='profile', action='dashboard'))
        return render('profile/add_student_group.mako')

    @ActionProtector("teacher")
    @validate(schema=StudentGroupForm, form='add_student_group', on_get=False)
    def edit_student_group(self, id):
        try:
            group = TeacherGroup.get(int(id))
        except ValueError:
            abort(404)

        if group is None or group.teacher != c.user:
            abort(404)

        c.student_group = group
        defaults = {
            'title' : group.title,
            'email' : group.email,
            'group_id' : group.id
            }
        if hasattr(self, 'form_result'):
            group.title = self.form_result['title']
            group.email = self.form_result['email']
            group.update_binding()
            meta.Session.commit()
            message = _(u'Group %(group_title)s (%(group_email)s) updated!') % {
                'group_title': group.title,
                'group_email': group.email}
            h.flash(message)
            redirect(url(controller='profile', action='dashboard'))
        return htmlfill.render(self._edit_student_group(), defaults=defaults)

    def _edit_student_group(self):
        return render('profile/edit_student_group.mako')

    @ActionProtector("teacher")
    @validate(schema=StudentGroupDeleteForm())
    def delete_student_group(self):
        if hasattr(self, 'form_result'):
            group = TeacherGroup.get(int(self.form_result['group_id']))
            if group is not None and group.teacher == c.user:
                message = _(u'Group %(group_title)s (%(group_email)s) was deleted.') % {
                    'group_title': group.title,
                    'group_email': group.email}
                meta.Session.delete(group)
                meta.Session.commit()
                h.flash(message)
            else:
                abort(404)
        redirect(url(controller='profile', action='dashboard'))

    @group_teacher_action
    @ActionProtector("group_teacher")
    @validate(schema=StudentGroupMessageForm())
    def studentgroup_send_message(self, group):
        if hasattr(self, 'form_result'):
            subject = self.form_result['subject']
            message = self.form_result['message']

            #wrap the message with additional information
            msg_text = render('/emails/teacher_message.mako',
                              extra_vars={'teacher':c.user,
                                          'subject':subject,
                                          'message':message})
            if group.group is not None:
                recipient = group.group
                if recipient.mailinglist_enabled:
                    attachments = []
                    if self.form_result['file'] != '':
                        file = self.form_result['file']
                        f = File(file.filename, file.filename, mimetype=file.type)
                        f.store(file.file)
                        meta.Session.add(f)
                        meta.Session.commit()
                        attachments.append(f)

                    post_message(recipient,
                                 c.user,
                                 subject,
                                 msg_text,
                                 force=True,
                                 attachments=attachments)
                else:
                    attachments = []
                    if self.form_result['file'] != '':
                        attachments = [{'filename': self.form_result['file'].filename,
                                        'file': self.form_result['file'].file}]

                    msg = EmailMessage(_('Message from %(teacher_name)s: %(subject)s') % {
                                           'subject': subject,
                                           'teacher_name': c.user.fullname},
                                       msg_text,
                                       sender=recipient.list_address,
                                       attachments=attachments)

                    msg.send(group.group)

                    evt = TeacherMessageEvent()
                    evt.context = group.group
                    evt.data = '%s \n\n %s' % (subject, msg_text)
                    evt.user = c.user
                    meta.Session.add(evt)
                    meta.Session.commit()

            else:
                attachments = []
                if self.form_result['file'] != '':
                    attachments = [{'filename': self.form_result['file'].filename,
                                    'file': self.form_result['file'].file}]

                msg = EmailMessage(subject, msg_text, sender=c.user.emails[0].email, force=True, attachments=attachments)
                msg.send(group.email)

            message = _(u'Message sent to %(group_title)s (%(group_email)s).') % {
                'group_title': group.title,
                'group_email': group.email}
            h.flash(message)

        redirect(url(controller='profile', action='dashboard'))
