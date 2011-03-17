<%inherit file="/group/base.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="css()">
   .members-invitations {
       margin-top: 1em;
       width: 280px;
       padding-right: 1em;
       border-right: 1px solid #ded8d8;
   }

   .members-invitations h2 {
      font-size: 16px;
      color: #666;
      font-weight: bold;
      padding-bottom: 8px;
    }

   .members-invitations button.submit {
      margin-top: 10px;
   }

   #member_invitation_form #emails {
      width: 260px;
   }

   .facebook-invitations {
      padding-top: 1em;
      width: 270px;
      text-align: center;
   }

   div.single-title {
      margin-top: 10px;
      margin-left: 10px;
      padding: 5px 0 5px 5px;
      background: none;
      border-bottom: 1px solid #ff9900;
   }

</%def>

<%def name="group_members(group=None)">
<%
   if group is None:
       group = c.group
%>

  <div class="single-title">
    <h2>
      ${_('Group members')}
    </h2>
    <div class="clear"></div>
  </div>


% for member in group.members:
  <div
     %if group.is_admin(member.user):
     class="user-logo-link admin-logo-link"
     %else:
     class="user-logo-link"
     %endif
  >

    <div class="user-logo">
      <a href="${url(controller="user", action="index", id=member.user.id)}"
         title="${member.user.fullname}">
        %if member.user.logo is not None:
          <img src="${url(controller='user', action='logo', id=member.user.id, width=60, height=70)}" alt="logo" />
        %else:
          ${h.image('/img/avatar-light.png', alt='logo')}
        %endif
      </a>
    </div>
    <div>
      <a href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}" class="link-to-user-profile">
        ${member.user.fullname}
      </a>
    </div>
  </div>
% endfor
</%def>


<%def name="group_members_invite_section(wizard=False)">
  <form method="post"
      %if not wizard:
      action="${url(controller='group', action='invite_members', id=c.group.group_id)}"
      %else:
      action="${url(controller='group', action='invite_members_step', id=c.group.group_id)}"
      %endif
      id="member_invitation_form" class="fullForm">

    <div class="floatleft members-invitations">
      <h2>${_('Invite your classmates')}</h2>
        <div class="explanation">
          ${_('Enter emails of your classmates.')}
        </div>
        <div class="invitation-emails">
          ${h.input_area('emails', '', cols=30)}
        </div>
        ${h.input_submit(_('Invite'))}
    </div>

    <div class="floatleft facebook-invitations">
      <h2 style="font-size: 16px; color: #666; font-weight: bold">${_('Invite your classmates using Facebook')}</h2>
      <div style="margin-top: 2em">
        <a href="${c.group.url(action='invite_fb')}">
          ${h.image('/img/facebook_pic.jpg', alt='Facebook')}
        </a>
      </div>
    </div>

    <div style="clear: both">&nbsp;</div>
    %if wizard:
      ${h.input_submit(_('Finish'), 'final_submit', class_='btnLarge')}
    %endif
  </form>
</%def>

${group_members_invite_section()}
${group_members(c.group)}
