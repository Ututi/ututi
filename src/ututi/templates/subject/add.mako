<%inherit file="/ubase.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/sections/standard_objects.mako" import="subject_listitem_minimal" />
<%namespace file="/search/index.mako" import="search_results" />

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
<script type="text/javascript">
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
});
</script>
</%def>

<%def name="list_similar_subjects(results)">
  %for n, item in enumerate(results):
    ${subject_listitem_minimal(item.object, n)}
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
    <script type="text/javascript">
    $(document).ready(function() {
      if ($('#location-edit .error-message').size() == 0) {
        $("#location-preview").show();
        $("#location-edit").hide();
        $("#location-edit-link").click(function() {
          $("#location-preview").hide();
          $("#location-edit").show();
          return false;
        });
      }
    });
    </script>
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
    ${_("Attention, please! Before creating new subject please ensure that it's not already there.")}
    ${_("A list of similar subjects to the one you are about to create is shown on the right.")}
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
      - ${_("""Upload and share your course materials (presentations, documents, links, images) with your students,
      entire school or all around the world.""")}
    </li>
    <li class="group">
      <strong>${_("Easy way to inform your students")}</strong>
      - ${_("when you update a subcet of or upload a new file, they will automatically get the notifications.")}
    </li>
    <li class="wiki">
      <strong>${_("Monitoring wiki notes")}</strong>
      - Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
      sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    </li>
    <li class="dialog">
      <strong>${_("Subject forum")}</strong>
      - Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
      sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    </li>
  </ul>
</%def>

<%def name="default_text_for_user()">
  <h1 class="page-title">${_("What are my subjects?")}</h1>
  <ul class="feature-list">
    <li class="file-sharing">
      <strong>${_("A place for course material sharing")}</strong>
      - ${_("""Upload and share your course materials (presentations, documents, links, images) with your students,
      entire school or all around the world.""")}
    </li>
    <li class="group">
      <strong>${_("Easy way to inform your students")}</strong>
      - ${_("when you update a subcet of or upload a new file, they will automatically get the notifications.")}
    </li>
    <li class="wiki">
      <strong>${_("Monitoring wiki notes")}</strong>
      - Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
      sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    </li>
    <li class="dialog">
      <strong>${_("Subject forum")}</strong>
      - Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
      sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
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
