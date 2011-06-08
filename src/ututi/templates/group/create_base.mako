<%inherit file="/profile/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*" />
<%namespace name="snippets" file="/sections/content_snippets.mako" import="group" />
<%namespace file="/elements.mako" import="tooltip" />

<%def name="css()">
  ${parent.css()}

  h1.page-title {
    margin-bottom: 20px;
  }

  .labelText {
    margin-top: 10px;
  }

  button.submit {
    margin-top: 15px;
  }

  #group-registration-steps {
    margin-bottom: 15px;
  }
     #group-registration-steps .step {
       margin-right: 20px;
       font-weight: noraml;
     }
     #group-registration-steps .step.active {
       font-weight: bold;
     }
  #group-id-check .taken {
      padding-left: 15px;
      background: transparent url("../img/icons/alert_small.png") left center no-repeat;
  }
  #group-id-check .free {
      padding-left: 15px;
      background: transparent url("../img/icons/tick_10.png") left center no-repeat;
  }
</%def>

<%def name="path_steps(step=1)">
<div id="group-registration-steps" class="steps">
  %for n, title in enumerate([_('Group settings'), _('Invite friends')], 1):
    <span class="step ${'active' if n == step else ''}">
      <span class="number">${n}</span>
      <span class="title">${title}</span>
    </span>
  %endfor
</div>
</%def>

<%def name="title()">
  ${_('Create group')}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  <%newlocationtag:head_tags />
  <script type="text/javascript">
  //<![CDATA[
  function check_group_id() {
    var id = $('input#group-id-field').val();
    if (id != '')
      $('#group-id-check').load("${url(controller='group', action='js_check_id')}", {'id': id});
  }
  function afterDelayedKeyup(selector, action, delay){
    jQuery(selector).keyup(function(){
      if(typeof(window['inputTimeout']) != "undefined") {
        clearTimeout(inputTimeout);
      }
      inputTimeout = setTimeout(action, delay);
    });
  }
  //]]>
  </script>
</%def>

<%def name="id_check_response(group_id, taken)">
%if taken:
  <p class="taken">
    <strong>${group_id}</strong>@${c.mailing_list_host} ${_('is invalid.')}
  </p >
%else:
  <p class="free">
    <strong>${group_id}</strong>@${c.mailing_list_host} ${_('is free!')}
  </p>
%endif
</%def>

<%def name="group_title_field()">
  ${h.input_line('title', _('Title:'))}
</%def>

<%def name="year_field()">
  ${h.select_line('year', _('Entrance year:'), c.years)}
</%def>

<%def name="can_add_subjects(enabled=True, tooltip_text=None)">
  <% disabled_attr = '' if enabled else ' disabled="disabled"' %>
  <label class="checkbox"${disabled_attr}>
    <input name="can_add_subjects" type="checkbox"${disabled_attr} />
    ${_("Group can subscribe to subjects")}
    %if tooltip_text is not None:
      ${tooltip(tooltip_text)}
    %endif
  </label>
</%def>

<%def name="has_file_storage(enabled=True, tooltip_text=None)">
  <% disabled_attr = '' if enabled else ' disabled="disabled"' %>
  <label class="checkbox"${disabled_attr}>
    <input name="file_storage" type="checkbox"${disabled_attr} />
    ${_("Group has a file storage area")}
    %if tooltip_text is not None:
      ${tooltip(tooltip_text)}
    %endif
  </label>
</%def>

<%def name="location_field()">
  ${standard_location_widget()}
</%def>

<%def name="logo_field()">
  <form:error name="logo_upload" />
    <label>
      <span class="labelText">${_('Picture:')}</span>
      <input type="file" name="logo_upload" id="logo_upload" />
  </label>
</%def>

<%def name="description_field()">
  ${h.input_area('description', _('Description:'))}
</%def>

<%def name="group_id()">
  <label for="group-id-field">
    <span class="labelText">${_("Email address:")}</span>
  </label>
  <label>
    <span class="textField">
      <input class="address" type="text" id="group-id-field" name="id" />
    </span>
    <span>@${c.mailing_list_host}</span>
    <form:error name="id" />
  </label>

  <div id="group-id-check"></div>
  <script type="text/javascript">
  //<![CDATA[
    afterDelayedKeyup('input#group-id-field', "check_group_id(true)", 500);
  //]]>
  </script>

</%def>

<%def name="moderators_field()">
  <div class="form-field">
    <label for="moderators">
      <input name="moderators" id="moderators" type="checkbox" />
      ${_("Moderators")}
    </label>
  </div>
</%def>

<%def name="live_search(groups)">
  %if groups:
    %for group in groups:
      ${snippets.group(group, list_members=True)}
    %endfor
  %else:
    <p class="notice">
      ${_('No groups found.')}
    </p>
  %endif
</%def>

<h1 class="page-title underline">${self.title()}</h1>

${next.body()}
