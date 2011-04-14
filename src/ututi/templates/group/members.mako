<%inherit file="/group/base_wide.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="css()">
   .members-invitations,
   .facebook-invitations {
       float: left;
       width: 280px;
       margin-top: 20px;
   }

   .members-invitations h2,
   .facebook-invitations h2 {
       font-size: 12px;
       font-weight: bold;
   }

   .members-invitations {
       padding-right: 20px;
       margin-right: 20px;
       border-right: 1px solid #666;
   }

   .members-invitations button.submit {
      margin-top: 10px;
   }

   #member_invitation_form #emails {
      width: 260px;
   }

   .facebook-invitations {
      text-align: center;
   }

   .facebook-invitations a {
      /* facebook button */
      display: block;
      margin: 20px auto;
      outline: none;
   }

   div.single-title {
      margin-top: 10px;
      margin-left: 10px;
      padding: 5px 0 5px 5px;
      background: none;
      border-bottom: 1px solid #ff9900;
   }

   ${parent.css()}
</%def>

<%def name="group_members(group=None)">
<%
   if group is None:
       group = c.group
%>


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

    <div class="clearfix">
      <div class="members-invitations">
        <h2>${_('Invite your groupmates')}</h2>
        ${h.input_area('emails', '', help_text=_('Enter emails of your classmates, separated with commas.'), cols=30)}
        ${h.input_submit(_('Invite'), class_='dark add inline')}
      </div>

      <div class="facebook-invitations">
        <h2>${_('Invite your groupmates using Facebook')}</h2>
        <a id="facebook-button" href="${c.group.url(action='invite_fb')}">
          ${h.image('/img/facebook-button.png', alt=_('Facebook'))}
        </a>
      </div>
    </div>

    %if wizard:
      ${h.input_submit(_('Finish'), 'final_submit')}
    %endif
  </form>
</%def>

${group_members_invite_section()}
${group_members(c.group)}
