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

  <div id="warning-text">
    <p>
    ${_("Attention, please! Before creating new subject please ensure that it's not already there.")}
    ${_("A list of similar subjects to the one you are about to create is shown on the right.")}
    ${_("Please carefully read through the list and if you don't find your subject, create it.")}
    </p>
  </div>

  <div>
    ${h.input_submit(_('Create subject'), class_='btnMedium', id='submit-button')}
    <a id="cancel-button" href="${c.cancel_url}">${_("Cancel")}</a>
  </div>

  </fieldset>
</form>
</%def>

<%def name="default_text_for_teacher()">
  <h1 class="page-title">${_("Teacher, subjects are good!")}</h1>
  <p>
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quis mi eu nibh dapibus lacinia sed eget enim. Curabitur lacus elit, mollis vitae bibendum a, consequat eget nibh. Vivamus accumsan rhoncus enim, eget viverra ligula pulvinar eget. Quisque dictum laoreet ultricies. Nam libero odio, elementum ac placerat id, porta quis lacus. Aliquam a lectus ac mauris eleifend varius vitae rhoncus erat. Nulla facilisi. Donec at porttitor tellus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec hendrerit, velit a posuere commodo, mauris quam posuere orci, ac mollis sem erat nec felis. Nullam luctus elementum hendrerit.
  </p>
  <p>
  Proin et arcu sit amet lacus aliquam aliquam. Suspendisse convallis, mi id molestie rutrum, risus quam rhoncus libero, vel convallis massa quam in ipsum. Duis ullamcorper sollicitudin lectus ac viverra. In molestie diam ac nunc egestas laoreet gravida nisi sagittis. Donec eget felis eget arcu accumsan laoreet. Ut hendrerit elementum arcu, ac dapibus lectus vestibulum sed. Sed vitae lacus quam. Etiam eu ligula tellus, et rhoncus lorem. Sed hendrerit suscipit adipiscing. Cras ac tortor tellus. Integer eu augue quis neque tempor pretium. Phasellus hendrerit, quam nec vestibulum feugiat, libero erat volutpat nisl, eget rutrum massa orci eu arcu. Nam lectus dui, cursus non imperdiet at, viverra at lorem. Aliquam mauris turpis, sagittis vitae tincidunt pharetra, feugiat quis purus. Aenean fermentum vehicula tellus, sit amet adipiscing mi ornare sit amet. Donec nec magna sed velit semper adipiscing pulvinar eget massa. Nulla tempor tellus eu odio laoreet tincidunt. Ut ut quam arcu, eu dignissim ante. Duis commodo erat et est porttitor accumsan. 
  </p>
</%def>

<%def name="default_text_for_user()">
  <h1 class="page-title">${_("User, subjects are good!")}</h1>
  <p>
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quis mi eu nibh dapibus lacinia sed eget enim. Curabitur lacus elit, mollis vitae bibendum a, consequat eget nibh. Vivamus accumsan rhoncus enim, eget viverra ligula pulvinar eget. Quisque dictum laoreet ultricies. Nam libero odio, elementum ac placerat id, porta quis lacus. Aliquam a lectus ac mauris eleifend varius vitae rhoncus erat. Nulla facilisi. Donec at porttitor tellus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec hendrerit, velit a posuere commodo, mauris quam posuere orci, ac mollis sem erat nec felis. Nullam luctus elementum hendrerit.
  </p>
  <p>
  Proin et arcu sit amet lacus aliquam aliquam. Suspendisse convallis, mi id molestie rutrum, risus quam rhoncus libero, vel convallis massa quam in ipsum. Duis ullamcorper sollicitudin lectus ac viverra. In molestie diam ac nunc egestas laoreet gravida nisi sagittis. Donec eget felis eget arcu accumsan laoreet. Ut hendrerit elementum arcu, ac dapibus lectus vestibulum sed. Sed vitae lacus quam. Etiam eu ligula tellus, et rhoncus lorem. Sed hendrerit suscipit adipiscing. Cras ac tortor tellus. Integer eu augue quis neque tempor pretium. Phasellus hendrerit, quam nec vestibulum feugiat, libero erat volutpat nisl, eget rutrum massa orci eu arcu. Nam lectus dui, cursus non imperdiet at, viverra at lorem. Aliquam mauris turpis, sagittis vitae tincidunt pharetra, feugiat quis purus. Aenean fermentum vehicula tellus, sit amet adipiscing mi ornare sit amet. Donec nec magna sed velit semper adipiscing pulvinar eget massa. Nulla tempor tellus eu odio laoreet tincidunt. Ut ut quam arcu, eu dignissim ante. Duis commodo erat et est porttitor accumsan. 
  </p>
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
