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

<%def name="group_members_invite_section()">
  <div class="floatleft" style="margin-top: 1em; width: 310px; padding-right: 1em; border-right: 1px solid #ded8d8">
    <h2 style="font-size: 16px; color: #666; font-weight: bold; padding-bottom: 8px">${_('Invite your classmates')}</h2>
    <form method="post" action="${url(controller='group', action='invite_members', id=c.group.group_id)}"
        id="member_invitation_form" class="fullForm">

      <div class="explanation">
        ${_('Enter emails of your classmates.')}
      </div>
      <div style="margin-bottom: 4px">
        ${h.input_area('emails', '', cols=37)}
      </div>
      ${h.input_submit(_('Invite'))}
    </form>
  </div>

  <div class="floatleft" style="padding-top: 1em; width: 300px; text-align: center">
    <h2 style="font-size: 16px; color: #666; font-weight: bold">${_('Invite your classmates using Facebook')}</h2>
    <div style="margin-top: 2em">
      <a href="${c.group.url(action='invite_fb')}">
        ${h.image('/img/facebook_pic.jpg', alt='Facebook')}
      </a>
    </div>
  </div>

  <div style="clear: both">&nbsp;</div>
</%def>

${group_members_invite_section()}
${group_members(c.group)}
