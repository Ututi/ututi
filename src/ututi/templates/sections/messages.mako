<%def name="confirmation_messages(user=None)">
<%
   if user is None and c.user is not None:
       user = c.user
%>
%if c.user and not c.user.isConfirmed:
<div class="flash-message">
  <span class="close-link hide-parent">${_('Close')}</span>
  <span>
    ${_('Your <strong>email</strong> is not confirmed! Please confirm your email by clicking on the link sent to your address or ')|n}
    <form method="post" action="${url(controller='profile', action='confirm_emails')}" id="email_confirmation_request" class="inline-form">
      <div>
        <input type="hidden" name="came_from" value="${request.url}" />
        <input type="hidden" name="email" value="${c.user.emails[0].email}" />
        <input type="submit" class="text_button" value="${_('get another confirmation email')}" style="font-size: 13px;"/>
      </div>
    </form>
  </span>
</div>
%endif

%if c.user and c.gg_enabled and c.user.gadugadu_uin is not None and not c.user.gadugadu_confirmed:
<div class="flash-message">
  <span class="close-link hide-parent">${_('Close')}</span>
  <span>
    ${_('Your <strong>gadu gadu number</strong> is not confirmed! Please confirm it by entering the code sent to you.')|n}
  </span>
</div>
%endif
</%def>

<%def name="invitation_messages(user=None)">
<%
   if user is None and c.user is not None:
       user = c.user
%>
%if user:
  %for invitation in user.invitations:
  <div class="flash-message">
    <span>
      ${_(u"%(author)s has sent you an invitation to group %(group)s. Do You want to become a member of this group?") % dict(author=invitation.author.fullname, group=invitation.group.title)}
    </span>
    <br />
    <form method="post"
          action="${url(controller='group', action='invitation', id=invitation.group.group_id)}"
          id="${invitation.group.group_id}_invitation_reject"
          class="inline-form">
      <div style="display: inline;">
        <input type="hidden" name="action" value="reject"/>
        <input type="hidden" name="came_from" value="${request.url}"/>
        <span class="btn">
          <input type="submit" name="invitation_reject" value="${_('Reject')}"/>
        </span>
      </div>
    </form>
    <form method="post"
          action="${url(controller='group', action='invitation', id=invitation.group.group_id)}"
          id="${invitation.group.group_id}_invitation_accept"
          class="inline-form">
      <div style="display: inline;">
        <input type="hidden" name="action" value="accept"/>
        <input type="hidden" name="came_from" value="${request.url}"/>
        <span class="btn">
          <input type="submit" name="invitation_accept" value="${_('Accept')}"/>
        </span>
      </div>
    </form>
  </div>
  %endfor
%endif

</%def>

<%def name="request_messages(user=None)">
<%
   if user is None and c.user is not None:
       user = c.user
%>
%if user:
  <%
     groups = [mship.group for mship in user.memberships if mship.membership_type == 'administrator' and mship.group.requests != []]
     requests = []
     for group in groups:
       requests.extend(group.requests)
  %>
  %for rq in requests:
  <div class="flash-message">
    <span>
      ${_(u"%(user)s wants to join the group %(group)s. Do You want to confirm his membership?") % dict(user=rq.user.fullname, group=rq.group.title)}
    </span>
    <br />
    <form style="display: inline;" method="post" action="${url(controller='group', action='request', id=rq.group.group_id)}">
      <div style="display: inline;">
        <input type="hidden" name="hash_code" value="${rq.hash}"/>
        <input type="hidden" name="action" value="confirm"/>
        <input type="hidden" name="came_from" value="${request.url}"/>
        <span class="btn">
          <input type="submit" value="${_('Confirm')}"/>
        </span>
      </div>
    </form>
    <form style="display: inline;" method="post" action="${url(controller='group', action='request', id=rq.group.group_id)}">
      <div style="display: inline;">
        <input type="hidden" name="hash_code" value="${rq.hash}"/>
        <input type="hidden" name="action" value="deny"/>
                <input type="hidden" name="came_from" value="${request.url}"/>
        <span class="btn">
          <input type="submit" style="color: #888;" value="${_('Deny')}"/>
        </span>
      </div>
    </form>


  </div>
  %endfor
%endif

</%def>
