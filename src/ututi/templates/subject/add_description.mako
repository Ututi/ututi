<%inherit file="/profile/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="head_tags()">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')}
</%def>

<%def name="css()">
${parent.css()}

.tag-widget {
  width: 560px;
}
.check-field {
  margin-top: 10px;
}
</%def>

<%def name="pagetitle()">
${_('Enter subject details')}
</%def>

<form method="post" action="${url(controller='subject', action='create')}" id="subject_add_form">
  <fieldset>

  <input type="hidden" name="title" value="" />
  <input type="hidden" name="location-0" value="" />
  <input type="hidden" name="location-1" value="" />

  %if c.user.is_teacher:
    <input type="hidden" name="lecturer" value="" />
  %else:
    ${h.input_line('lecturer', _('Lecturer:'))}
  %endif

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

  %if not c.user.is_teacher:
  <div class="formField check-field">
    <label for="watch_subject">
      <input type="checkbox" name="watch_subject" id="watch_subject" value="watch" />
      ${_('I want to follow this subject')}
    </label>
  </div>
  %endif

  ${h.input_submit(_('Create'))}

  </fieldset>
</form>
