<%inherit file="/ubase-sidebar.mako" />

<%namespace file="/group/add.mako" import="path_steps"/>
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<h1>${_('Add group members')}</h1>

${path_steps(1)}

<form method="post" action="${url(controller='group', action='invite_members_step', id=c.group.group_id)}" id="member_invitation_form">

  <div>
    ${h.input_area('emails', _('Enter emails of the people you would like to invite to the group.'), '', '50', '8')}
  </div>

  <div>
    ${h.input_submit(_('Invite'))}
    ${h.input_submit(_('Continue'), 'final_submit')}
  </div>
</form>

