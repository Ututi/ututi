import simplejson

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
from ututi.lib.validators import js_validate


from ututi.model import meta, File, TeacherGroup
from ututi.model.events import TeacherMessageEvent
from ututi.controllers.profile.base import ProfileControllerBase
from ututi.controllers.profile.validators import BiographyForm, \
        StudentGroupForm, StudentGroupDeleteForm, StudentGroupMessageForm

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

    def _actions(self, selected):
        """Generate a list of all possible actions.

        The action with the name matching the `selected' parameter is
        marked as selected.
        """
        bcs = {
            'home':
            {'title': _("Home"),
             'link': url(controller='profile', action='home')},
            'feed':
            {'title': _("What's New?"),
             'link': url(controller='profile', action='feed')},
            }
        if selected in bcs.keys():
            return bcs[selected]

    @ActionProtector("teacher")
    def home(self):
        if c.user.is_freshman():
            redirect(url(controller='profile', action='get_started'))
        else:
            redirect(url(controller='profile', action='dashboard'))

    @ActionProtector("teacher")
    def get_started(self):
        return render('/profile/teacher/get_started.mako')

    @ActionProtector("teacher")
    def dashboard(self):
        return render('/profile/teacher/dashboard.mako')

    def _set_settings_tabs(self, current_tab):
        c.current_tab = current_tab
        c.tabs = [
            {'title': _("General information"),
             'name': 'general',
             'link': url(controller='profile', action='edit')},
            {'title': _("Contacts"),
             'name': 'contacts',
             'link': url(controller='profile', action='edit_contacts')},
            {'title': _("Biography"),
             'name': 'biography',
             'link': url(controller='profile', action='edit_biography')},
            {'title': _("Wall"),
             'name': 'wall',
             'link': url(controller='profile', action='wall_settings')},
            {'title': _("Notifications"),
             'name': 'notifications',
             'link': url(controller='profile', action='notifications')}]

    def _edit_biography_form(self):
        self._set_settings_tabs(current_tab='biography')
        return render('profile/teacher/edit_biography.mako')

    @ActionProtector("user")
    def edit_biography(self):
        return htmlfill.render(self._edit_biography_form(),
                               defaults=self._edit_form_defaults())

    @validate(schema=BiographyForm, form='_edit_biography_form')
    @ActionProtector("user")
    def update_biography(self):
        if not hasattr(self, 'form_result'):
            redirect(url(controller='profile', action='edit_biography'))

        c.user.description = self.form_result.get('description', None)
        meta.Session.commit()
        h.flash(_('Your biography was updated.'))

        redirect(url(controller='profile', action='edit_biography'))

    @ActionProtector("teacher")
    @validate(schema=StudentGroupForm, form='add_student_group', on_get=False)
    def add_student_group(self):
        if hasattr(self, 'form_result'):
            grp = TeacherGroup(self.form_result['title'],
                               self.form_result['email'])
            c.user.student_groups.append(grp)
            meta.Session.commit()
            h.flash(_('Group added!'))
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
            h.flash(_('Group updated!'))
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
                meta.Session.delete(group)
                meta.Session.commit()
                h.flash(_('Group deleted.'))
            else:
                abort(404)
        redirect(url(controller='profile', action='dashboard'))

    @group_teacher_action
    @ActionProtector("group_teacher")
    @validate(schema=StudentGroupMessageForm())
    def studentgroup_send_message(self, group):
        if hasattr(self, 'form_result'):
            return self._studentgroup_send_message(group)

    @group_teacher_action
    @ActionProtector("group_teacher")
    @js_validate(schema=StudentGroupMessageForm())
    def studentgroup_send_message_js(self, group):
        if hasattr(self, 'form_result'):
            output = self._studentgroup_send_message(group, js=True)
            return simplejson.dumps(output)

    def _studentgroup_send_message(self, group, js=False):
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

                    msg = EmailMessage(_('Message from Your teacher: %s') % subject,
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

            if js:
                return {'success': True}
            else:
                h.flash(_('Message sent.'))
                redirect(url(controller='profile', action='dashboard'))
