<%inherit file="/subject/base_two_sidebar.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
  ${_('Subject permissions')}
</%def>

<%def name="body()">
<a class="back-link" href="${url(controller='subject', action='home', id=c.subject.subject_id, tags=c.subject.location_path)}">${_('Back to subject')}</a>
<h2>${_('Subject permissions')}</h2>
<div class="permissions">
  <form name='permission_settings' action="${c.subject.url(action='change_permissions')}" method="POST">
    <fieldset>
      ${h.select_line('subject_visibility', _('Who can view the subject'),
                      [('everyone', _('Everyone')),
                       ('department_members', _('Department members')),
                       ('university_members', _('University members'))],
                      selected=c.subject.visibility)}
      ${h.select_line('subject_edit', _('Who can change subject settings'),
                      [('everyone', _('Everyone')),
                       ('teachers_and_admins', _('Teachers and administrators'))],
                      selected=c.subject.edit_settings_perm )}
      ${h.select_line('subject_post_discussions', _('Who can post subject discussions'),
                      [('everyone', _('Everyone')),
                       ('teachers', _('Teachers'))],
                      selected=c.subject.post_discussion_perm)}
    </fieldset>
    <button>${_('Save')}</button>
  </form>
</div>
</%def>
