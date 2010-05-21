<%inherit file="/ubase.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="title()">
  ${_('Create group')} <!-- Override this -->
</%def>

<%def name="flash_messages()"></%def>

<%def name="head_tags()">
    ${parent.head_tags()}
    <%newlocationtag:head_tags />
</%def>

<%def name="portlets()">
<div id="sidebar">
  <div class="search-header">
    ${_('Recommended groups from your university and faculty')}
  </div>
  <div class="message">
    ${_('Enter your university and faculty and you will be able to see groups that are already here. If you find your group, join them!')}
  </div>
</div>
</%def>


<%def name="path_steps(step=0)">
<div id="steps">
  %for index, title in enumerate([_('Group settings'), _('Member invitations')]):
<%
   cls=''
   if step == index:
       cls='active'%>
    <span class="step ${cls}">
      <span class="number">${index + 1}</span>
      <span class="title">${title}</span>
    </span>
  %endfor
</div>
</%def>


<%def name="group_title_field()">
  ${h.input_line('title', _('Group title'))}
</%def>

<%def name="web_address_field()">
  <label for="group-id-field">
    <span class="labelText">${_("Group address on the web")}</span>
  </label>
  <label>
    <span class="address">${url(controller='group', action='', qualified=True)}</span>
    <form:error name="id" />
    <span class="textField">
      <input class="address" type="text" id="group-id-field" name="id" />
      <span class="edge"></span>
    </span>
  </label>
</%def>


<%def name="location_field()">
  ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=True)}
</%def>

<%def name="logo_field()">
  <form:error name="logo_upload" />
    <label>
      <span class="labelText">${_('Group logo')}</span>
      <input type="file" name="logo_upload" id="logo_upload" class="line"/>
  </label>
</%def>

<%def name="description_field()">
  ${h.input_area('description', _('Description'))}
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
<div class="search-header">
  ${_('Recommended groups from your university and faculty')}
</div>
%if len(groups) > 0:
  %for group in groups:
    <div class="live_search_group">
      <div class="group_logo">
        <img class="group_logo" src="${group.url(action='logo', height=70, width=70)}" alt="${group.title}" />
      </div>
      <div class="group_information">
        <div>
          <a class="group_title" href="${group.url()}" title="${group.title}">${h.ellipsis(group.title, 30)}</a>
          <a class="btn" href="${group.url()}"><span>${_('join')}</span></a>
        </div>
        <div class="group_members">
          %for member in group.last_seen_members[:4]:
          <div class="group_member">
            <div class="member_logo">
              <a href="${member.url()}" title="${member.fullname}">
                <img src="${member.url(action='logo', height="15", width="15")}" alt="${member.fullname}" />
              </a>
            </div>
            ${h.ellipsis(member.fullname, 20)}
          </div>
          %endfor
        </div>
      </div>
    </div>
  %endfor
  <br class="clear-left" />
%else:
  <span>${_('No groups found')}</span>
%endif
</%def>

<%def name="group_live_search_js()">
<script type="text/javascript">
//<![CDATA[
  $(document).ready(function() {
    $('.group_live_search').change(function() {
      parameters = {'location-0': $('#location-0-0').val(),
                    'location-1': $('#location-0-1').val(),
                    'year': $('#year').val()}
      $('#sidebar').load(
          '${url(controller="group", action="js_group_search")}',
          parameters);
    });
  });
//]]>
</script>
</%def>

<%def name="right_pane(title)">
  <div id="CreatePubliCGroupRight">
    <h1 class="pageTitle">${title}</h1>
      ${caller.body()}
  </div>
</%def>
