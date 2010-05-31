<%inherit file="/subject/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('Edit subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<a class="back-link" href="${url(controller='subject', action='home', id=c.subject.subject_id, tags=c.subject.location_path)}">${_('back to the subject')}</a>
<h1>${_('Edit subject')}</h1>

<form method="post" action="${url(controller='subject', action='update', id=c.subject.subject_id, tags=c.subject.location_path)}"
     id="subject_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
  <input type="hidden" name="id" value=""/>
  <input type="hidden" name="old_location" value=""/>
  ${h.input_line('title', _('Title'))}
  ${h.input_line('lecturer', _('Lecturer'))}
  ${location_widget(2)}
  <br class="clear-left"/>
  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget()}
  </div>
  <br />
  <div class="form-field">
    <label for="description">${_('Brief description of the subject')}</label>
    <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  <br />
  <div>
    ${h.input_submit(_('Save'))}
  </div>
  </fieldset>
</form>
