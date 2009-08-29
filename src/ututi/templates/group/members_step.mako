<%inherit file="/group/home.mako" />
<%namespace file="/group/add.mako" import="path_steps"/>

<%def name="title()">
${c.group.title}
</%def>

<h1>${_('Group members')}</h1>

${path_steps(2)}

<form method="post" action="${url(controller='group', action='invite_members_step', id=c.group.group_id)}" id="member_invitation_form">

  <div class="form-field">
    <label for="emails">${_('Enter emails of the people You would like to invite to the group.')}</label>
    <textarea name="emails" id="emails" rows="8" cols="60"></textarea>
  </div>

  <div class="form-field">
    <span class="btn"><input type="submit" value="${_('Invite')}"/></span>
    <a href="${url(controller='group', action='group_home', id=c.group.group_id)}" title="${_('Group home')}" class="btn">
      <span>
        ${_("Finish and go to group's main page")}
      </span>
    </a>
  </div>
</form>

