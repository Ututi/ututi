<%inherit file="/group/base_wide.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="css()">
   .members-invitations {
       float: left;
       width: 280px;
       margin-top: 20px;
   }

   .members-invitations h2 {
       font-size: 12px;
       font-weight: bold;
   }

   .members-invitations {
       padding-right: 20px;
       margin-right: 20px;
   }

   .members-invitations button.submit {
      margin-top: 10px;
   }

   #member_invitation_form #emails {
      width: 260px;
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
        <img src="${member.user.url(action='logo', width=60)}" alt="logo" />
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
      action="${c.group.url(action='invite_members')}"
      %else:
      action="${c.group.url(action='invite_members_step')}"
      %endif
      id="member_invitation_form">

    <div class="clearfix">
      <div class="members-invitations">
        <h2>${_('Invite your groupmates')}</h2>
        ${h.input_area('emails', '', help_text=_('Enter emails of your classmates, separated with commas.'), cols=30)}
        ${h.input_submit(_('Invite'), class_='dark add inline')}
      </div>
    </div>

    %if wizard:
      ${h.input_submit(_('Finish'), 'final_submit')}
    %endif
  </form>
</%def>

${group_members_invite_section()}
${group_members(c.group)}
