<%inherit file="/ubase.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
</%def>

<%def name="form(action, personal=False)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<form method="post" action="${action}"
     id="subject_add_form" enctype="multipart/form-data" class="fullForm">
  <fieldset>

  ${h.input_line('title', _('Title'))}

  %if c.user.is_teacher:
    <input type="hidden" name="lecturer" value="${c.user.fullname}" />
  %else:
    ${h.input_line('lecturer', _('Lecturer'))}
  %endif

  %if c.user.location is not None:
  <div id="location-preview">
    ${item_location(c.user)}
    <a id="location-edit-link" href="#">${_("Edit")}</a>
  </div>
  <div id="location-edit">
    ${location_widget(2, values=c.user.location.hierarchy(), add_new=(c.tpl_lang=='pl'))}
  </div>
  <script type="text/javascript">
  $(document).ready(function() {
    $("#location-preview").show();
    $("#location-edit").hide();
    $("#location-edit-link").click(function() {
      $("#location-preview").hide();
      $("#location-edit").show();
      return false;
    });
  });
  </script>
  %else:
    ${location_widget(2, add_new=(c.tpl_lang=='pl'))}
  %endif

  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget()}
  </div>

  <div class="form-field">
    <label for="description">${_('Brief description of the subject')}</label>
    <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  %if not c.user.is_teacher:
  <div class="form-field check-field">
    <label for="watch_subject">
      <input type="checkbox" name="watch_subject" id="watch_subject" value="watch"/>
      ${_('Start watching this subject personally')}
    </label>
  </div>
  %endif

  <div>
    ${h.input_submit(_('Save'))}
  </div>

  </fieldset>
</form>
</%def>

<div class="two-panel-layout with-right-panel">
  <div class="left-panel">
    <h1 class="pageTitle">${_('New subject')}</h1>

    <%self:form action="${url(controller='subject', action='create')}" personal="True"/>
  </div>
  <div class="right-panel">
    <h1 class="pageTitle">${_('Existing subjects')}</h1>
    <div style="width:100%; margin:1cm; font-size:100px; color: #888; text-align:center">
      TODO
    </div>
  </div>
</div>
