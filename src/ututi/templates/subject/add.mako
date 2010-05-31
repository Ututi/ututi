<%inherit file="/subject/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('New subject')}
</%def>

<%def name="portlets()">
  ${ututi_prizes_portlet()}
  ${user_support_portlet()}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
</%def>

<a class="back-link" href="${url(controller='profile', action='search')}">${_('back to search')}</a>
<h1>${_('New subject')}</h1>

<%def name="form(action, personal=False)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<form method="post" action="${action}"
     id="subject_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>
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
  <div class="form-field check-field">
    <label for="watch_subject">
      <input type="checkbox" name="watch_subject" id="watch_subject" value="watch"/>
      ${_('Start watching this subject personally')}
    </label>
  </div>
  <br />
  <div>
    ${h.input_submit(_('Save'))}
  </div>
  </fieldset>
</form>
</%def>

<%self:form action="${url(controller='subject', action='create')}" personal="True"/>
