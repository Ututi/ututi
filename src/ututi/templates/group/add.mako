<%inherit file="/base.mako" />
<%namespace file="/widgets/newlocationtag.mako" import="*"/>

<%def name="flash_messages()"></%def>

<%def name="body_class()">
split6040
</%def>

<%def name="head_tags()">
    ${parent.head_tags()}
    ${h.stylesheet_link('/stylesheets/group.css')|n}
    ${h.stylesheet_link('/stylesheets/newlocationwidget.css')|n}
</%def>

<%def name="title()">
${_('New group')}
</%def>

<%def name="portlets()">
<div id="sidebar">
  <div class="header">
    ${_('Recommended groups from your university and faculty')}
  </div>
  <div class="message">
    ${_('Enter your university and faculty and you will be able to see groups that are already here. If you find your group, join them!')}
  </div>
</div>
</%def>


<%def name="path_steps(step=0)">
<div id="steps">
  %for index, title in enumerate([_('Group settings'), _('Member invitations'), _('Subject selection')]):
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

<h1>${_('Create your Ututi group and start sharing!')}
  ${h.image('/images/details/icon_question.png',
            alt=_('Create your group, invite your classmates and use the mailing list, upload private group files'),
            class_='tooltip')|n}
</h1>

${path_steps()}

<form method="post" action="${url(controller='group', action='new_group')}"
     id="group_add_form" enctype="multipart/form-data">

  <div class="form-field">
    ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=True)}
  </div>
  <br class="clear-left"/>
  ${h.input_line('title', _('Group title'))}
  <div class="form-field">
    <label for="id">${_("Group email address")}</label>
    <form:error name="id" />
    <div class="input-line"><div>
        <input type="text" id="id" name="id" class="line"/>
    </div></div>
    @${c.mailing_list_host}
    <div class="explanation">${_("Your group's email address at Ututi")}</div>
  </div>
  <div class="form-field">
    <label for="year">${_("Year")}</label>
    <form:error name="year" />
    <select name="year" id="year" class="group_live_search">
      %for year in c.years:
      <option value="${year}">${year}</option>
      %endfor
    </select>
  </div>
  <div class="form-field">
    <label for="logo_upload">${_('Group logo')}</label>
    <form:error name="logo_upload" />
    <input type="file" name="logo_upload" id="logo_upload" class="line"/>
  </div>
  ${h.input_area('description', _('Description'))}
<%
from ututi.lib.security import is_root
%>
% if is_root(c.user):
  <div class="form-field">
    <label for="moderators">${_("Moderators")}</label>
    <input name="moderators" id="moderators" type="checkbox" />
  </div>
% endif

  ${h.input_submit(_('Continue'))}
</form>
<script type="text/javascript">
//<![CDATA[
  $(document).ready(function() {
    $('.group_live_search').change(function() {
      parameters = {'location-0' : $('#location-0').val(),
                    'location-1' : $('#location-1').val(),
                    'year'       : $('#year').val()}
      $('#sidebar').load(
          '${url(controller="group", action="js_group_search")}',
          parameters);
    });

  });
//]]>
</script>

<%def name="live_search(groups)">
<div class="header">
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
          <a class="group_title" href="${group.url()}" title="${group.title}">${h.ellipsis(group.title, 40)}</a>
          <a class="btn" href="${group.url()}"><span>${_('join')}</span></a>
        </div>
        <div class="group_members">
          %for member in group.last_seen_members[:4]:
          <div class="group_member">
            <div class="member_logo">
              <a href="${member.url()}" title="${member.fullname}">
                <img src="${member.url(action='logo', height="20", width="20")}" alt="${member.fullname}" />
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
