<%inherit file="/ubase.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/profile/watch_subjects.mako" import="search_subject" />
<%namespace file="/search/index.mako" import="search_results" />

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
<script type="text/javascript">
$(document).ready(function() {
  $('#subject-search-results').hide();
  $('#subject_add_form input').blur(function() {
    var search_url = $('#subject_add_form input#subject-search-url').attr('value');
    $.post(
      search_url,
      $(this).closest('form').serialize(),
      function(data, status) {
        if (data.success) {
          $('#subject-search-results').html(data.search_results);
          $('#subject-search-results').show();
          $('#no-results-text').hide();
        }
        else {
          $('#subject-search-results').hide();
          $('#no-results-text').show();
        }
      }
    );
  });
});
</script>
</%def>

<%def name="list_similar_subjects(results)">
  <div id="search-results-container">
    <div id="search-results">
      %for item in results:
        ${search_subject(item)}
      %endfor
    </div>
  </div>
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

  <div>
    ${h.input_submit(_('Save'))}
  </div>

  </fieldset>
</form>
</%def>

<div id="subject-add-page">
  <div class="two-panel-layout with-right-panel">
    <div class="left-panel">
      <h1 class="page-title">${_('Create subject you teach:')}</h1>

      <%self:form action="${url(controller='subject', action='create')}" personal="True"/>
    </div>

    <div class="right-panel">

      <h1 class="page-title">${_("Maybe here's what you're looking for?")}</h1>

      <div id="subject-search-results">
      </div>

      <div id="no-results-text">
        There really is no meaning to this and that!
      </div>
    </div>
  </div>
</div>
