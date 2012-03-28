<%inherit file="/profile/home_base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="css()">
  ${parent.css()}
  #subject-features {
    float: right;
    width: 200px;
  }
  #location-edit-link {
    margin-left: 15px;
  }
</%def>

<%def name="pagetitle()">
${_('Create new subject')}
</%def>

<%def name="head_tags()">
  <%newlocationtag:head_tags />
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')}
</%def>

<%b:title_box title="${_('Subject features:')}" id="subject-features">
  <ul class="feature-list small">
    <li class="files">${_("Upload and share course material")}</li>
    <li class="discussions">${_("Discuss with other people interested in the subject")}
    <li class="wiki">${_("Put lecture notes to subject page and edit them together")}</li>
    <li class="notifications">${_("Get notifications related to this subject")}</li>
  </ul>
</%b:title_box>

<%def name="form(action)">
<form method="post" action="${action}" id="subject_add_form" class="narrow">
  <fieldset>
  ${standard_location_widget()}
  ${h.input_line('title', _('Subject title:'),
    help_text=_("It's best to use exactly the same title that is used in your university for this subject. It does not need to be unique."))}
  ${h.input_line('lecturer', _('Subject lecturer:'))}
  <div class="formField">
    <label for="description">
      <span class="labelText">${_('Subject description:')}</span>
    </label>
    <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
  </div>
  ${h.input_submit(_('Next'))}
  </fieldset>
</form>
</%def>

<%self:form action="${url(controller='subject', action='lookup')}" />
