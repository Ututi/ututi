<%inherit file="/ubase.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/sections/standard_objects.mako" import="subject_listitem_search_results" />
<%namespace file="/search/index.mako" import="search_results" />

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
${h.javascript_link('/javascript/equalheights.js')}
<script type="text/javascript">
function equalHeights() {
  // Ugne's madness
  $('.two-panel-layout').equalHeights();
  setTimeout("equalHeights()", 1000);
}
$(document).ready(function() {
  $('#subject_add_form input').blur(function() {
    var search_url = $('#subject_add_form input#subject-search-url').attr('value');
    $.post(
      search_url,
      $(this).closest('form').serialize(),
      function(data, status) {
        if (data.success) {
          $('#subject-search-results').html(data.search_results);
          $('#subject-add-page').addClass('with-similar-subjects');
        }
        else {
          $('#subject-search-results').empty();
          $('.with-similar-subjects').removeClass('with-similar-subjects');
        }
      }
    );
  });
  if ($('#location-edit .error-message').size() == 0) {
    $("#location-preview").show();
    $("#location-edit").hide();
    $("#location-edit-link").click(function() {
      $("#location-preview").hide();
      $("#location-edit").show();
      return false;
    });
  }
  equalHeights();
});
</script>
</%def>

<%def name="list_similar_subjects(results)">
  %for n, item in enumerate(results):
    ${subject_listitem_search_results(item.object, 0)}
  %endfor
</%def>

<%def name="form(action, personal=False)">
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<form method="post" action="${action}"
     id="subject_add_form" enctype="multipart/form-data" class="fullForm">

  <input id="subject-search-url" type="hidden" value="${url(controller='subject', action='js_search_similar')}" />

  <fieldset>
  ${h.input_line('title', _('Subject title:'))}

  %if c.user.is_teacher:
    <input type="hidden" name="lecturer" value="${c.user.fullname}" />
  %else:
    ${h.input_line('lecturer', _('Lecturer:'))}
  %endif

  <input type="hidden" name="came_from" value="${c.came_from}" />

  <div class="formField">
    %if c.user.location is not None:
    <div id="location-preview">
      <label for="tags">${_('University / department:')}</label>
      ${item_location_full(c.user)}
      <a id="location-edit-link" style="float: right" href="#edit-location">${_("Edit")}</a>
    </div>
    <div id="location-edit">
      <a name="edit-location"></a>
      ${location_widget(2, titles=(_("University:"), _("Department:")),
        values=c.user.location.hierarchy(), add_new=(c.tpl_lang=='pl'))}
    </div>
    %else:
      ${location_widget(2, titles=(_("University:"), _("Department:")), add_new=(c.tpl_lang=='pl'))}
    %endif
  </div>

  <div class="formField">
    <label for="tags">${_('Tags:')}</label>
    ${tags_widget()}
  </div>

  <div class="formField">
    <label for="description">${_('Subject description:')}</label>
    <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  %if not c.user.is_teacher:
  <div class="formField check-field">
    <label for="watch_subject">
      <input type="checkbox" name="watch_subject" id="watch_subject" value="watch"/>
      ${_('Start watching this subject personally')}
    </label>
  </div>
  %endif

  <div id="warning-text">
    ${_("Before creating a new subject please ensure that it has not been created yet.")}
    ${_("A list of similar subjects is shown on the right.")}
    ${_("Please carefully read through the list and if you don't find your subject, create it.")}
  </div>

  <div>
    ${h.input_submit(_('Create subject'), class_='btnMedium', id='submit-button')}
    <a id="cancel-button" href="${c.came_from}">${_("Cancel")}</a>
  </div>

  </fieldset>
</form>
</%def>

<%def name="default_text_for_teacher()">
  <h1 class="page-title">${_("What are my subjects?")}</h1>
  <ul class="feature-list">
    <li class="file-sharing">
      <strong>${_("A place for course material sharing")}</strong>
      - ${_("upload and share course material with students of your class, university or the entire world.")}
    </li>
    <li class="group">
      <strong>${_("Easy way to reach your students")}</strong>
      - ${_("send messages to all of your students at once.")}
      ${_("When you update subject information or upload a new file, your students will be notified automatically.")}
    </li>
    <li class="wiki">
      <strong>${_("Monitoring wiki notes")}</strong>
      - ${_("create notes for your courses collaboratively with your students.")}
    </li>
    <li class="dialog">
      <strong>${_("Subject forum")}</strong>
      - ${_("a place to discuss the learning matters. Subject forums bring you to your students closer than ever before!")}
    </li>
  </ul>
</%def>

<%def name="default_text_for_user()">
  <h1 class="page-title">${_("What are subjects?")}</h1>
  <ul class="feature-list">
    <li class="file-sharing">
      <strong>${_("A place for course material sharing")}</strong>
      - ${_("upload and share course material with students of your class, university or the entire world.")}
    </li>
    <li class="group">
      <strong>${_("Easy way to reach your university mates")}</strong>
      - ${_("send messages to all of your group mates at once.")}
      ${_("When someone updates subject information or uploads a new file, everyone watching the subject will be notified automatically.")}
    </li>
    <li class="wiki">
      <strong>${_("Creating wiki notes")}</strong>
      - ${_("create notes for your courses collaboratively with your group mates or even your teacher.")}
    </li>
    <li class="dialog">
      <strong>${_("Subject forum")}</strong>
      - ${_("a place to discuss the learning matters!")}
    </li>
  </ul>
</%def>

<div id="subject-add-page">
  <div class="two-panel-layout with-right-panel">
    <div class="left-panel">
      <h1 class="page-title">${_('Create subject you teach:')}</h1>

      <%self:form action="${url(controller='subject', action='create')}" personal="True"/>

    ## Note, that here below affects rendering!
    </div><div class="separator"></div><div class="right-panel">

      <div id="default-text">
        %if c.user.is_teacher and c.user.teacher_verified:
          ${default_text_for_teacher()}
        %else:
          ${default_text_for_user()}
        %endif
      </div>

      <div id="similar-subjects">
        <h1 class="page-title">${_("Maybe here's what you're looking for?")}</h1>
        <p>
        ${_("Please make sure that the subject you are about to create is not in this list.")}
        </p>
        <div id="subject-search-results">
          <!-- Search results will be here -->
        </div>
      </div>

    </div>
  </div>
</div>
