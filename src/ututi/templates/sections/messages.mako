<%namespace file="/prebase.mako" import="rounded_block" name="b"/>
<%namespace file="/widgets/ulocationtag.mako" import="location_widget, head_tags" name="loc"/>
<%namespace file="/widgets/vote.mako" name="v" import="voting_widget" />

<%def name="confirmation_messages(user=None)">
<%
   if user is None and c.user is not None:
       user = c.user
%>
%if c.user and not c.user.isConfirmed:
<div class="flash-message">
  <span class="close-link hide-parent">
    ${h.image('/images/details/icon_delete.png', alt=_('Close'))}
  </span>
  <span>
    ${_('Your email (%(email)s) is not confirmed! '
    'Please confirm your email by clicking on the link sent '
    'to your address or ') % dict(email=c.user.emails[0].email) |n}
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
  <span class="close-link hide-parent">
    ${h.image('/images/details/icon_delete.png', alt=_('Close'))}
  </span>
  <span>
    ${_('Your <strong>gadu gadu number</strong> is not confirmed! Please <a href="%s">confirm</a> it by entering the code sent to you.') % url(controller='profile', action='edit')|n}
  </span>
</div>
%endif

%if c.user and c.gg_enabled and c.user.phone_number is not None and not c.user.phone_confirmed:
<div class="flash-message" id="confirm-phone-flash-message">
  <span class="close-link hide-parent">
    ${h.image('/images/details/icon_delete.png', alt=_('Close'))}
  </span>
  <span>
    ${_('Your phone is not confirmed! Please <a href="%s">confirm</a> it by entering the code sent to you.') % url(controller='profile', action='edit')|n}
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
    % if invitation.active:
      <div class="flash-message">
        <span>
          ${h.literal(_(u"%(author)s has sent you an invitation to group %(group)s. Do you want to become a member of this group?") %\
                      dict(author=h.object_link(invitation.author), group=h.object_link(invitation.group)))}
        </span>
        <br />
        <form method="post"
              action="${url(controller='group', action='invitation', id=invitation.group.group_id)}"
              id="${invitation.group.group_id}_invitation_reject"
              class="inline-form">
          <div style="display: inline;">
            <input type="hidden" name="action" value="reject"/>
            <input type="hidden" name="came_from" value="${request.url}"/>
            ${h.input_submit(_('Reject'))}
          </div>
        </form>
        <form method="post"
              action="${url(controller='group', action='invitation', id=invitation.group.group_id)}"
              id="${invitation.group.group_id}_invitation_accept"
              class="inline-form">
          <div style="display: inline;">
            <input type="hidden" name="action" value="accept"/>
            <input type="hidden" name="came_from" value="${request.url}"/>
            ${h.input_submit(_('Accept'))}
          </div>
        </form>
      </div>
    %endif
  %endfor
%endif

</%def>

<%def name="request_messages(user=None)">
<%
   if user is None and c.user is not None:
       user = c.user
%>
%if user:
  %for rq in user.group_requests():
  <div class="flash-message">
    <span>
      ${_(u"%(user)s wants to join the group %(group)s. Do you want to confirm this membership?") % \
        dict(user=h.object_link(rq.user), group=h.object_link(rq.group))|n}
    </span>
    <br />
    <form style="display: inline;" method="post" action="${url(controller='group', action='request', id=rq.group.group_id)}">
      <div style="display: inline;">
        <input type="hidden" name="hash_code" value="${rq.hash}"/>
        <input type="hidden" name="action" value="confirm"/>
        <input type="hidden" name="came_from" value="${request.url}"/>
        ${h.input_submit(_('Confirm'))}
      </div>
    </form>
    <form style="display: inline;" method="post" action="${url(controller='group', action='request', id=rq.group.group_id)}">
      <div style="display: inline;">
        <input type="hidden" name="hash_code" value="${rq.hash}"/>
        <input type="hidden" name="action" value="deny"/>
                <input type="hidden" name="came_from" value="${request.url}"/>
        ${h.input_submit(_('Deny'))}
      </div>
    </form>


  </div>
  %endfor
%endif
</%def>

<%def name="voting_message(user)">
<div id="transfer_voting">
<%b:rounded_block class_="orange-block">
  <div class="content">
    <h3>${_('Ututi is growing!')}</h3>
    <div>
    ${_("After two years of development and service here in Lithuania , Ututi is growing and changing."
        " This March we are planning to release a new version, that will be not only a study material"
        " exchange platform. Ututi will become Your university's social network and will connect not"
        " only students but also teachers.")}
    </div>
    ${h.link_to(h.image('/img/transition.png', 'transition'), url(controller='home', action='dotcom'))}
    <div>
    ${_("Going in this new direction, we have decided to transition only the universities that have"
        " an active community. If You want Your university to be a part of the new Ututi this March,"
        " vote here. Only univerisites with 500 votes or more will be transfered.")}
    </div>
    %if user.location is None:
      ${loc.head_tags()}
      <script type="text/javascript">
        $(function(){
            $('#location-submit, #location-submit span').click(function(){
                var form = $(this).closest('form');
                var url = $(form).find('#js_url').val();
                $.post(url,
                       $(form).serialize(),
                       function(data){
                           $('#location-setting').hide();
                           $.get("${url(controller='profile', action='voting_widget')}",
                                 function(data) {
                                   $('#transfer_voting').replaceWith(data);
                                 });
                       });
                return false;
            });
        });
      </script>
      <div id="location-setting">
        <form method="post" action="${url(controller='profile', action='update_location_universal')}">
          <input type="hidden" id="js_url" name="js_url" value="${url(controller='profile', action='js_update_location_universal')}"/>
          <div>
            <span style="float: left; margin-right:5px;">${_('Choose Your university:')}</span>
            <div style="float: left;">
              ${loc.location_widget(1, titles=[''])}
            </div>
            <div style="float: right;">
              ${h.input_submit(_('Confirm'), id='location-submit')}
            </div>
          </div>
        </form>
        <br style="clear: both;"/>
      </div>
    %elif not user.has_voted:
      <%
         votes = user.location.vote_count()
      %>
      ${v.voting_widget(votes)}
      <br class="clear-both"/>
    %endif
    <div id="voting-results" style="${user.has_voted and '' or 'display: none;'}">
      ${_('Thank You for voting, check out how Your university is doing!')}
    </div>
  </div>
</%b:rounded_block>
</div>
</%def>
