<%inherit file="/ubase.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<%def name="title()">
  ${_('Create group')} <!-- Override this -->
</%def>

<%def name="flash_messages()"></%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  <%newlocationtag:head_tags />
  <script type="text/javascript">
  //<![CDATA[
  function check_group_id(is_email) {
    var id = $('input#group-id-field').val();
    $('#group-id-check').load("${url(controller='group', action='js_check_id')}",
           {'id': id, 'is_email': is_email});
  }

  function afterDelayedKeyup(selector, action, delay){
    jQuery(selector).keyup(function(){
      if(typeof(window['inputTimeout']) != "undefined"){
        clearTimeout(inputTimeout);
      }
      inputTimeout = setTimeout(action, delay);
    });
  }

  //]]>
  </script>

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

<%def name="id_check_response(group_id, taken, is_email)">
<div>
<span class="${'taken' if taken else 'free'}">
  %if is_email:
  <span class="bold">${group_id}</span>@${c.mailing_list_host}
  %else:
  http://ututi.lt/group/<span class="bold">${group_id}</span>
  %endif
  %if taken:
    <span class="grey">${_(' is taken.')}</span>
  %else:
    <span class="green">${_(' is free!')}</span>
  %endif
</span>
</div>
</%def>

<%def name="group_title_field()">
  ${h.input_line('title', _('Group title'), id='group-title-field')}
</%def>

<%def name="year_field()">
  <label for="year"><span class="labelText">${_("Year")}</span></label>
  <form:error name="year" />
  <select name="year" id="year" class="group_live_search">
    <option value="">${_('Select the year')}</option>
    %for year in c.years:
      <option value="${year}">${year}</option>
    %endfor
  </select>
</%def>

<%def name="web_address_field()">
  <label for="group-id-field">
    <span class="labelText">${_("Group address on the web")}</span>
  </label>
  <label>
    <form:error name="id" />
    <span class="address">${url(controller='group', action='', qualified=True)}</span>
    <span class="textField">
      <input class="address" type="text" id="group-id-field" name="id" />
      <span class="edge"></span>
    </span>
  </label>
  <div id="group-id-check"></div>
  <script type="text/javascript">
  //<![CDATA[
    afterDelayedKeyup('input#group-id-field',"check_group_id(false)",500);
  //]]>
  </script>

</%def>

<%def name="group_email_field()">
  <label for="group-id-field">
    <span class="labelText">${_("Group e-mail address")}</span>
  </label>
  <label>
    <form:error name="id" />
    <span class="textField">
      <input class="address" type="text" id="group-id-field" name="id" />
      <span class="edge"></span>
    </span>
     @${c.mailing_list_host}
  </label>
  <div id="group-id-check"></div>
  <script type="text/javascript">
  //<![CDATA[
    afterDelayedKeyup('input#group-id-field',"check_group_id(true)",500);
  //]]>
  </script>

</%def>

<%def name="can_add_subjects()">
  <label class="checkbox">
    <input name="can_add_subjects" type="checkbox" />
    ${_("Group can subscribe to subjects")}
  </label>
</%def>

<%def name="has_file_storage()">
  <label class="checkbox">
    <input name="file_storage" type="checkbox" />
    ${_("Group has a file storage area")}
  </label>
</%def>

<%def name="location_field(live_search=True)">
  ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=live_search)}
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
  <br />
</%def>

<%def name="forum_type()">
  <label for="forum_type"><span class="labelText">${_('Forum type')}</span></label>
  ${h.select("forum_type", c.forum_type, c.forum_types)}
</%def>

<%def name="forum_type_and_id()">
  <label for="forum_type"><span class="labelText">${_('Forum type')}</span></label>
  ${h.select("forum_type", c.forum_type, c.forum_types)}

  <label for="group-id-field">
    <span class="labelText mailinglist-choice">${_("Group e-mail address")}</span>
    <span class="labelText forum-choice" style="display: none">${_("Group address on the web")}</span>
  </label>
  <label>
    <form:error name="id" />
    <span class="address forum-choice" style="display: none">${url(controller='group', action='', qualified=True)}</span>
    <span class="textField">
      <input class="address" type="text" id="group-id-field" name="id" />
      <span class="edge"></span>
    </span>
    <span class="mailinglist-choice">@groups.ututi.lt</span>
  </label>

  <div id="group-id-check"></div>
  <script type="text/javascript">
  //<![CDATA[
    afterDelayedKeyup('input#group-id-field', "check_group_id(true)",500);
  //]]>
  </script>

  <script type="text/javascript">
  //<![CDATA[
      $(document).ready(function() {
          $('select#forum_type').change(function() {
              if (this.value == 'mailinglist') {
                  $('.mailinglist-choice').show();
                  $('.forum-choice').hide();
              } else {
                  $('.forum-choice').show();
                  $('.mailinglist-choice').hide();
              };
          });
      });
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
<h1 class="pageTitle">
  ${_('Recommended groups')}
</h1>
%if len(groups) > 0:
  %for group in groups:
    <div class="live_search_group">
      <div class="group_logo">
          <img height="70" width="70" class="group_logo"
               src="${group.url(action='logo', height=70, width=70)}"
               alt="${group.title}" />
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
                  <img height="15" width="15"
                       src="${member.url(action='logo', height="15", width="15")}"
                       alt="${member.fullname}" />
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
    $('select.group_live_search').change(function() {
      parameters = {'location-0': $('#location-0-0').val(),
                    'location-1': $('#location-0-1').val(),
                    'year': $('#year').val()}
      $('div.group-type-info').hide();
      $('#sidebar').load(
          '${url(controller="group", action="js_group_search")}',
          parameters);
    });
  });
//]]>
</script>
</%def>

<%def name="right_pane(title, sidebar=True)">
  <div id="CreatePublicGroupRight">
    <div class="group-type-info">
      <h1 class="pageTitle">${title}</h1>
        ${caller.body()}

        %if sidebar:
          <ul>
            <li>${_('Enter your university and department')}</li>
            <li>${_('Find existing groups')}</li>
            <li>${_('Join one')}</li>
          </ul>
        %endif

    </div>

    <div id="sidebar">
        ##<div class="search-header">
        ##  ${_('Recommended groups from your university and faculty')}
        ##</div>
        ##<div class="message">
        ##  ${_('Enter your university and faculty and you will be able to see groups that are already here. If you find your group, join them!')}
        ##</div>
    </div>
  </div>

</%def>

<%def name="access_settings()">
  <h2>${_('Access settings')}</h2>

  <label for="approve_new_members" class="radio">
    <span class="labelText">${_('New members')}</span>
    ${h.radio("approve_new_members", "none",
      label=_('Anyone can join the group any time'))}
    <br />
    ${h.radio("approve_new_members", "admin",
      label=_('Administrators have to approve new members'))}
  </label>

  <label for="forum_visibility" class="radio">
    <span class="labelText">${_('Group forum and mailing list visibility')}</span>
    ${h.radio("forum_visibility", "public", label=_('Public'))}
    <br />
    ${h.radio("forum_visibility", "members", label=_('Members only'))}
  </label>

  <label for="page_visibility" class="radio">
    <span class="labelText">${_('Group page visibility')}</span>
    ${h.radio("page_visibility", "public", label=_('Public'))}
    <br />
    ${h.radio("page_visibility", "members", label=_('Members only'))}
  </label>
</%def>

${next.body()}
