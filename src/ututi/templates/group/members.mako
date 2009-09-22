<%inherit file="/group/home.mako" />
<%namespace file="/portlets/group.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
  ${group_changes_portlet()}
</div>
</%def>



<%def name="title()">
  ${c.group.title}
</%def>

<h1>${_('Members')}</h1>

<%def name="group_members(group=None)">
<%
   if group is None:
       group = c.group
%>
% for member in group.members:
  <div class="user-logo-link">
    <div class="user-logo">
      <a href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
        %if member.user.logo is not None:
          <img src="${url(controller='user', action='logo', id=member.user.id, width=60, height=60)}" alt="logo" />
        %else:
          ${h.image('/images/user_logo_60x60.png', alt='logo')|n}
        %endif
      </a>
    </div>
    <div>
      <a href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
        ${member.user.fullname}
      </a>
    </div>
  </div>
% endfor
</%def>


${group_members(c.group)}
<div style="clear: left;">
  <h2>${_('Invite your group mates')}</h2>
  <form method="post" action="${url(controller='group', action='invite_members', id=c.group.group_id)}" id="member_invitation_form">

    <div class="form-field">
      <label for="emails">${_('Enter emails of the people You would like to invite to the group.')}</label>
      <textarea name="emails" id="emails" rows="8" cols="60"></textarea>
    </div>

    <div class="form-field">
      <span class="btn"><input type="submit" value="${_('Invite')}"/></span>
    </div>
  </form>
</div>
