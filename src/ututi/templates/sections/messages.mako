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
    <br/>
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
