<%inherit file="/subject/base_two_sidebar.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
  ${_('Edit subject')}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  <%newlocationtag:head_tags />
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<%def name="subject_permissions()">
</%def>

<a class="back-link" href="${url(controller='subject', action='home', id=c.subject.subject_id, tags=c.subject.location_path)}">${_('Back to subject')}</a>

<h2 style="margin-top: 10px">${_("Edit subject's info")}</h2>

<form method="post" action="${url(controller='subject', action='update', id=c.subject.subject_id, tags=c.subject.location_path)}"
     id="subject_add_form" enctype="multipart/form-data" class="fullForm">

  <fieldset>
  <input type="hidden" name="id" value=""/>
  <input type="hidden" name="old_location" value=""/>
  ${h.input_line('title', _('Subject title:'))}

  <div class="formField">
    ${hidden_fields(c.subject.location)}
    <div id="location-preview">
      <label for="tags">
        <span class="labelText">${_('University | Department:')}</span>
      </label>
      ${item_location_full(c.subject)}
    </div>
  </div>

  ${h.input_line('lecturer', _('Lecturer:'))}

  <div class="formField">
    <label for="tags">
      <span class="labelText">${_('Tags:')}</span>
    </label>
    ${tags_widget()}
  </div>

  <div class="formField">
    <label for="description">
      <span class="labelText">${_('Subject description:')}</span>
    </label>
    <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  %if c.show_permission_settings:
    ${h.select_line('subject_visibility', _('Who can view the subject'),\
                    [(u'everyone', _('Everyone')),\
                     (u'department_members', _('Department members')),\
                     (u'university_members', _('University members'))],\
                    selected=c.subject.visibility)}
    ${h.select_line('subject_edit', _('Who can change subject settings'),
                    [(u'everyone', _('Everyone')),
                     (u'teachers_and_admins', _('Teachers and administrators'))],
                    selected=c.subject.edit_settings_perm )}
    ${h.select_line('subject_post_discussions', _('Who can post subject discussions'),
                    [(u'everyone', _('Everyone')),
                     (u'teachers', _('Teachers'))],
                    selected=c.subject.post_discussion_perm)}
  %endif

  <div>
    ${h.input_submit(_('Save'))}
  </div>

  </fieldset>
</form>
