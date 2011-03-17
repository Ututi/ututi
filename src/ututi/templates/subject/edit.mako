<%inherit file="/subject/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('Edit subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<h1 class="page-title with-bottom-line">${c.subject.title}</h1>

<a class="back-link" href="${url(controller='subject', action='home', id=c.subject.subject_id, tags=c.subject.location_path)}">${_('Back to subject')}</a>

<h2 style="margin-top: 10px">${_("Edit subject's info")}</h2>

<form method="post" action="${url(controller='subject', action='update', id=c.subject.subject_id, tags=c.subject.location_path)}"
     id="subject_add_form" enctype="multipart/form-data" class="fullForm">

  <fieldset>
  <input type="hidden" name="id" value=""/>
  <input type="hidden" name="old_location" value=""/>
  ${h.input_line('title', _('Subject title'))}

  <div class="formField">
    %if hasattr(c, 'hide_location'):
    <div id="location-preview" style="display: none">
      <label for="tags">
        <span class="labelText">${_('University | Department:')}</span>
      </label>
      ${item_location_full(c.subject)}
      <a id="location-edit-link" href="#">${_("Change")}</a>
    </div>
    <script type="text/javascript">
      $(document).ready(function() {
        $('#location-preview').show();
        $('#location-edit').hide();
        $('#location-edit-link').click(function() {
          $('#location-preview').hide();
          $('#location-edit').show();
          return false;
        });
      })
    </script>
    %endif
    <div id="location-edit">
      ${location_widget(2, titles=(_("University:"), _("Department:")), add_new=(c.tpl_lang=='pl'))}
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

  <div>
    ${h.input_submit(_('Save'))}
  </div>

  </fieldset>
</form>
