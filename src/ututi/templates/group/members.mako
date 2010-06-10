<%inherit file="/group/base.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

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
          <img src="${url(controller='user', action='logo', id=member.user.id, width=60, height=70)}" alt="logo" />
        %else:
          ${h.image('/img/avatar-light.png', alt='logo')}
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

<div style="clear: left; margin: 20px 0;">
  <h2>${_('Invite your group mates')}</h2>
  <form method="post" action="${url(controller='group', action='invite_members', id=c.group.group_id)}"
      id="member_invitation_form" class="fullForm hideLabels">

    ${h.input_area('emails', _('Enter emails of the people you would like to invite to the group.'))}
    <br />
    ${h.input_submit(_('Invite'))}
  </form>
</div>

${group_members(c.group)}
