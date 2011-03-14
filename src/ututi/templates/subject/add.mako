<%inherit file="/profile/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="css()">
  ${parent.css()}
  #location-edit-link {
    margin-left: 15px;
  }
</%def>

<%def name="pagetitle()">
${_('Create new subject')}
</%def>

<%def name="head_tags()">
  <%newlocationtag:head_tags />
</%def>

<%def name="form(action)">
<form method="post" action="${action}" id="subject_add_form">

  <fieldset>

  <div class="formField">
    %if hasattr(c, 'hide_location'):
    <div id="location-preview" style="display: none">
      <label for="tags">
        <span class="labelText">${_('University | Department:')}</span>
      </label>
      ${item_location_full(c.user)}
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

  ${h.input_line('title', _('Subject title:'))}

  ${h.input_submit(_('Next'))}

  </fieldset>
</form>
</%def>

<%self:form action="${url(controller='subject', action='lookup')}" />
