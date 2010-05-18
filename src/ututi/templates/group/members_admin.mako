<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.javascript_link('/javascript/forms.js')|n}
</%def>


<div>
  <h2>${_('Invite your group mates')}</h2>
  <form method="post" action="${url(controller='group', action='invite_members', id=c.group.group_id)}" id="member_invitation_form">

    <div class="form-field">
      <label for="emails">${_('Enter emails of the people you would like to invite to the group.')}</label>
      <textarea name="emails" id="emails" rows="8" cols="60"></textarea>
    </div>

    <div class="form-field">
      <span class="btn"><input type="submit" value="${_('Invite')}"/></span>
    </div>
  </form>
</div>

%if c.group.invitations:
<div>
  <h2>${_('Invited users (invitations not accepted yet)')}</h2>
  <table class="group-invitations">
  % for invitation in c.group.invitations:
  <tr>
    <td class="date">
      ${h.fmt_dt(invitation.created)}
    </td>
    <td class="email">
      ${invitation.email}
    </td>
    <td class="actions">
      <form style="display: inline;" method="post" action="${url(controller='group', action='invite_members', id=c.group.group_id)}">
        <div style="display: inline;">
          <input type="hidden" name="emails" value="${invitation.email}" />
          <input type="submit" class="text_button" value="${_('Send invitation again')}"/>
        </div>
      </form>

      <form style="display: inline;" method="post" action="${url(controller='group', id=c.group.group_id, action='cancel_invitation')}">
        <div style="display: inline;">
          <input type="hidden" name="email" value="${invitation.email}" />
          <input type="submit" class="text_button" style="color: #888;" value="${_('Cancel invitation')}"/>
        </div>
      </form>
    </td>
  </tr>
  % endfor
  </table>
</div>
%endif

%if c.group.requests:
<div>
  <h2>${_('Awaiting confirmation')}</h2>
  <table class="group-requests">
  % for request in c.group.requests:
  <tr>
    <td class="email">
      <a href="${url(controller='user', action='index', id=request.user.id)}" title="${request.user.fullname}">
        ${request.user.fullname}
      </a>
      (${request.user.emails[0].email})
    </td>
    <td class="actions">
      <form style="display: inline;" method="post" action="${url(controller='group', action='request', id=c.group.group_id)}">
        <div style="display: inline;">
          <input type="hidden" name="hash_code" value="${request.hash}"/>
          <input type="hidden" name="action" value="confirm"/>
          <input type="submit" class="text_button" value="${_('Confirm')}"/>
        </div>
      </form>
      <form style="display: inline;" method="post" action="${url(controller='group', action='request', id=c.group.group_id)}">
        <div style="display: inline;">
          <input type="hidden" name="hash_code" value="${request.hash}"/>
          <input type="hidden" name="action" value="deny"/>
          <input type="submit" class="text_button" style="color: #888;" value="${_('Deny')}"/>
        </div>
      </form>
    </td>
  </tr>
  % endfor
  </table>
</div>
%endif

<h2>${_('Group members')}</h2>
<table class="group-members">
  <tr>
    <th>${_('Name')}</th>
    <th>${_('Email')}</th>
    <th>${_('Last seen')}</th>
    <th>${_('Status')}</th>
  </tr>
% for member in c.members:
  <tr>
    <td>
      <a href="${member['user'].url()}" title="${member['title']}">
        ${member['title']}
      </a>
    </td>
    <td>
      ${member['user'].emails[0].email}
    </td>
    <td>
      ${member['last_seen']}
    </td>
    <td>
      <form method="post" action="${c.group.url(action='update_membership')}" class="autosubmit-form" id="update-membership-${member['user'].id}">
        <div>
          <input type="hidden" name="user_id" value="${member['user'].id}"/>
          <select name="role">
            %for role in member['roles']:
              %if role['selected']:
                <option value="${role['type']}" selected="selected">${role['title']}</option>
              %else:
                <option value="${role['type']}">${role['title']}</option>
              %endif
            %endfor
          </select>
          <span class="btn">
            <input type="submit" value="${_('Update')}"/>
          </span>
        </div>
      </form>
    </td>
  </tr>
% endfor
</table>
%if len(c.group.members) == 1:
<br />
${h.button_to(_('Delete group'), c.group.url(action='delete'))}
%endif
