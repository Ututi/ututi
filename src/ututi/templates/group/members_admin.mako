<%inherit file="/group/base_wide.mako" />
<%namespace name="members" file="/group/members.mako" import="group_members_invite_section, css"/>
<%namespace file="/portlets/base.mako" import="uportlet"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.javascript_link('/javascript/forms.js')|n}
</%def>

<%def name="css()">
   ${parent.css()}
   ${members.css()}
</%def>

${group_members_invite_section()}

%if [inv for inv in c.group.invitations if inv.active and inv.email]:
<div id="invited-members">
  <div class="single-title">
    <h2 class="portletTitle bold category-title">
      ${_('Invited users (invitations not accepted yet)')}
    </h2>
    <div class="clear"></div>
  </div>

  <table class="group-invitations" style="width: 100%">
    %for invitation in sorted(c.group.invitations, key=lambda inv: inv.created):
    %if invitation.active and invitation.email:
      <tr>
          <td class="date">
          ${h.fmt_dt(invitation.created)}
        </td>
        <td class="email">
          ${invitation.email}
        </td>
        <td class="actions">
          <form style="display: inline;" method="post" action="${url(controller='group', action='invite_members', id=c.group.group_id)}">
              <input type="hidden" name="emails" value="${invitation.email}" />
              <input type="submit" class="text_button" value="${_('Send again')}" />
          </form>

          <form style="display: inline;" method="post" action="${url(controller='group', id=c.group.group_id, action='cancel_invitation')}">
              <input type="hidden" name="email" value="${invitation.email}" />
              <input type="submit" class="text_button" style="color: #888;" value="${_('Cancel')}" />
          </form>
        </td>
      </tr>
    %endif
  %endfor
  </table>
</div>
%endif

%if c.group.requests:
<div>
  <div class="single-title">
    <div class="floatleft bigbutton2">
      <h2 class="portletTitle bold category-title">
        ${_('Awaiting confirmation')}
      </h2>
    </div>
    <div class="clear"></div>
  </div>

  <table class="group-requests">
  % for request in c.group.requests:
  <tr>
    <td class="email">
      <a href="${url(controller='user', action='index', id=request.user.id)}" title="${request.user.fullname}"
         >${request.user.fullname}
      </a>
      (${request.user.email.email})
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

<div>
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>
  <div class="single-title">
    <div class="floatleft bigbutton2">
      <h2 class="portletTitle bold category-title">
        ${_('Group members')}
      </h2>
    </div>
    <div class="clear"></div>
  </div>

  <table class="group-members">
    <tr>
      <th>${_('User')}</th>
      <th style="text-align: center">${_('Phone number')}</th>
      <th>${_('Last seen')}</th>
      <th>${_('Status')}</th>
    </tr>
    % for i, member in enumerate(c.members):
    <tr ${"class='last'" if i == len(c.members)-1 else ""}>
      <td class="member-info">
        <a href="${member['user'].url()}" title="${member['title']}">
          ${member['title']}
        </a>
        <div>
          ${member['user'].email.email}
        </div>
      </td>
      <td class="phone">
        % if member['user'].phone_number:
          ${member['user'].phone_number if member['user'].phone_confirmed else _('unconfirmed')}
        % else:
          -
        % endif
      </td>
      <td class="last-seen">
        ${member['last_seen']}
      </td>
      <td class="actions">
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
      </td>    </tr>
  % endfor
  </table>
</div>

%if len(c.group.members) == 1:
<br />
${h.button_to(_('Delete group'), c.group.url(action='delete'))}
%endif
