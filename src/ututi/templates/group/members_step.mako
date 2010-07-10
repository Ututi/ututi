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

<div class="floatleft" style="padding-top: 10px; width: 400px">
  <form method="post"
    action="${url(controller='group', action='invite_members_step', id=c.group.group_id)}"
    id="member_invitation_form">

    ${h.input_area('emails', _('Enter emails of the people you would like to invite to the group.'), '', '50', '8')}
    <br />
    ${h.input_submit(_('Invite'))}
    ${h.input_submit(_('Continue'), 'final_submit')}
  </form>
</div>


<div class="floatleft" style="padding-top: 1em; width: 220px; text-align: center">
  <h2>${_('Invite using Facebook')}</h2>
  <div style="margin-top: 1em">
    <a href="${c.group.url(action='invite_fb')}">
      ${h.image('/img/facebook_pic.jpg', alt='Facebook')}
    </a>
  </div>
</div>
