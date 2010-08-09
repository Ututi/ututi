<%inherit file="/portlets/base.mako"/>

<%def name="portlet_file(file)">
  <li>
    <a href="${file.url()}" title="${file.title}">${h.ellipsis(file.title, 30)}</a>
    <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
  </li>
</%def>

<%def name="group_info_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:uportlet id="group_info_portlet" portlet_class="MyProfile first">

    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')} href="${group.url()}" title="${group.title}">${_('Group information')}</a>
    </%def>

    <div class="profile">
      <div class="floatleft avatar">
        <img id="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=70, height=70)}" alt="logo" />
      </div>
      <div class="floatleft personal-data">
        <div><h2 class="grupes-portlete">${group.title}</h2></div>
        %if not c.group.forum_is_public:
        <div>
          <a href="${group.location.url()}">${' | '.join(group.location.title_path)}</a>
          <span class="right_arrow"></span>
        </div>
        %else:
        <div style="width: 190px">
          <a href="${group.url()}">${group.url(qualified=True)}</a>
        </div>
        %endif
        %if not c.group.forum_is_public:
        <div>
          %if group.is_member(c.user):
            <a href="${url(controller='mailinglist', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
          %elif c.user is not None:
            <a href="${url(controller='mailinglist', action='new_anonymous_post', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a>
          %endif
        </div>
        %endif
        <div>${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count=len(group.members))}</div>
      </div>
      ##<div style="float: left; margin-top: 3px">
      ##  <fb:like width="90" show_faces="false" url=${group.url(qualified=True)}></fb:like>
      ##</div>
      <div class="clear"></div>
    </div>
    %if (group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator'])) and group.has_file_area:
    <div class="profile topLine grey">
      <span class="bold">${_('Remaining private space:')}</span>
      <span>${h.file_size(group.free_size)}</span>
      ${h.image('/images/details/pbar%d.png' % group.free_size_points, alt=h.file_size(group.size), class_='area_size_points')|n}
      <div style="padding-top: 4px; padding-bottom: 7px" class="bottomLine">
        <form>
          ${h.input_submit(_('Get more space'), id='get-space-button')}
        </form>
      </div>

          <div id="get-space-dialog" class="payment-dialog" style="display: none">
              <div class="description">

  ${_("The amount of group's private files is limited to %(limit)s. This is so because Ututi "
  "encourages users to store their files in publicly accessible subjects where they can "
  "be shared with all the users. But if you want to keep more than %(limit)s of files, "
  "you can do this.") % dict(limit=h.file_size(c.group_file_limit))}

              </div>
              <div style="clear: both"></div>

              <div class="left-column">
                  <div class="title">
                      ${_('SMS message')}
                  </div>
                  <div>
                    ${_('Send an SMS message to number <span style="font-size: 14px">%(phone)s</span> with the following content:') % dict(phone=c.pylons_config.get('fortumo.phone_number', '1337')) |n}
                  </div>
                  <div class="sms-content">TXT ${c.pylons_config.get('fortumo.group_space.code')} ${c.group.group_id}</div>
                  <div>
                    ${_('The SMS costs <strong>7 Lt</strong> and will increase your file limit to <strong>5&nbsp;GB</strong> for another month.')|n}
                  </div>
                  %if c.group.private_files_lock_date:
                    <div>${_('Your private file area is limited to 5&nbsp;GB until <strong>%s</strong>.') % c.group.private_files_lock_date.date().isoformat() |n}</div>
                  %endif
              </div>

              <div class="right-column">
                <div class="title">
                  ${_('E-banking')}
                </div>
                <div class="description">
                  ${_('If you pay by bank, a discount applies.')|n}
                </div>

                <table>

                  %for period, amount, form in c.filearea_payments:
                    <tr>
                      <td>
                      <form action="${form.action}" method="POST">
                        %for key, val in form.fields:
                          <input type="hidden" name="${key}" value="${val}" />
                        %endfor
                        ${h.input_submit(_('%d Lt') % (int(amount) / 100), class_='btnMedium')}
                      </form>
                      </td>
                      <td>
                        <span class="larger">
                          - ${period}
                        </span>
                      </td>
                    </tr>

                  %endfor

                </table>

              </div>
          </div>

          <script>
            $('#get-space-button').click(function() {
                var dlg = $('#get-space-dialog').dialog({
                    title: '${_('Purchase group private space')}',
                    width: 600
                });
                dlg.dialog("open");
                return false;
            });
          </script>
    </div>
    %endif

    %if group.is_member(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
    <div class="click2show">
      <div class="click more_settings">
        <span class="green verysmall">${_("More settings")}</span>
      </div>
      <div class="show" id="group_settings_block">
        %if group.is_subscribed(c.user):
        <div style="display: inline-block; padding-top: 8px">
          ${h.button_to(_("Do not get email"), group.url(action='unsubscribe'), class_='btn inactive')}
        </div>
        %else:
        <div style="display: inline-block; padding-top: 8px">
          ${h.button_to(_("Get email"), group.url(action='subscribe'), class_='btn')}
        </div>
        %endif
        <div style="display: inline-block; padding-top: 8px">
          ${h.button_to(_("Leave group"), group.url(action='leave'), class_='btn warning')}
        </div>
      </div>
    </div>
    %endif

    %if group.is_admin(c.user) or c.security_context and h.check_crowds(['admin', 'moderator']):
      <div class="floatright">
      <span class="right_arrow">
        <a href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
      </span>
    </div>
    %endif
    <br class="clear-right" />
  </%self:uportlet>
</%def>

<%def name="group_forum_post_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="forum_post_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'group_forum_post', 'action_portlets')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}">${_('email your group')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Write an email to the group's forum - accessible by all your classmates."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="group_invite_member_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="invite_member_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'group_invite_members', 'action_portlets')} href="${group.url(action='members')}">${_('invite classmates')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Invite your classmates to use Ututi with you."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="group_members_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:uportlet id="group_info_portlet" portlet_class="MyProfile first">

    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')} href="${group.url(action='members')}" title="${_('''Group's members''')}">${_("Group's members")}</a>
    </%def>
    <div class="members_list">
      %for member in group.members[:8]:
        <div class="user-logo-link">
          <div class="user-logo">
            <a href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
              %if member.user.logo is not None:
                <img src="${url(controller='user', action='logo', id=member.user.id, width=45, height=45)}" alt="logo" />
              %else:
                ${h.image('/img/avatar-light-small.png', alt='logo')}
              %endif
            </a>
          </div>
          <div>
            <a class="verysmall blark" href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
              ${h.ellipsis(member.user.fullname, 10)}
            </a>
          </div>
        </div>
      %endfor
        <br class="clear-left" />
    </div>
    %if not group.is_member(c.user):
      ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=group.group_id))}
    %endif
  </%self:uportlet>
</%def>

<%def name="group_sms_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:uportlet id="group_sms_portlet" portlet_class="MyProfile">
    <%def name="header()">
      ${_('Send SMS message to group')}
    </%def>

    <div class="credits-remaining">
      <div class="sms-intro">
        ${_('Send an SMS message to all your classmates. The service is paid by SMS credits (1 credit = 1 SMS message to one person). The cost of an SMS message depends on the number of members in the group.')}
      </div>

      <div class="credit-info">
        <span class="credits-header">${_('Credits left:')}</span>
        <span class="num-credits-remaining ${'shortage' if not c.user.can_send_sms(group) else ''}">${c.user.sms_messages_remaining}</span>
        <div style="float: right">
          <form>
            ${h.input_submit(_('Purchase credits'), id='purchase-credits-button')}
          </form>
        </div>
      </div>

        <div id="purchase-credits-dialog" class="payment-dialog" style="display: none">
            <div class="description">
              ${_('SMS credits can be used to send SMS messages to members of a group. There are two ways to purchase SMS credits:')}
            </div>
            <div style="clear: both"></div>

            <div class="left-column">
                <div class="title">
                    ${_('SMS message')}
                </div>
                <div>
                  ${_('Send an SMS message to number <span style="font-size: 14px">%(phone)s</span> with the following content:') % dict(phone=c.pylons_config.get('fortumo.phone_number', '1337')) |n}
                </div>
                <div class="sms-content">TXT ${c.pylons_config.get('fortumo.personal_sms_credits.code')} ${c.group.group_id}</div>
                <div>
                  ${_('The SMS costs <strong>5 Lt</strong> and <strong>50 credits</strong> will be added to your account (one credit is one SMS to a single person).')|n}
                </div>
            </div>

            <div class="right-column">
                <div class="title">
                    ${_('E-banking')}
                </div>
                <div class="description">
                    ${_('If you pay by bank, <strong>a large discount applies</strong>.')|n}
                </div>

                <table>
                  %for credits, amount, form in c.sms_payments:
                    <tr>
                      <td>
                      <form action="${form.action}" method="POST">
                        %for key, val in form.fields:
                          <input type="hidden" name="${key}" value="${val}" />
                        %endfor
                        ${h.input_submit(_('%d Lt') % (int(amount) / 100), class_='btnMedium')}
                      </form>
                      </td>
                      <td>
                        <span class="larger">
                          <span class="old-price">${amount / 10}</span>
                          <span class="new-price">${credits}</span>
                          ${_('credits')}
                        </span>
                      </td>
                    </tr>

                  %endfor
                </table>

            </div>
        </div>

        <script>
        //<![CDATA[
            $('#purchase-credits-button').click(function() {
                var dlg = $('#purchase-credits-dialog').dialog({
                    title: '${_('Purchase SMS credits')}',
                    width: 600
                });
                dlg.dialog("open");
                return false;
            });
        //]]>
        </script>
    </div>

    <div class="sms-box">
      <span>${_('Message text:')}</span>
      <span class="recipients">${_('Recipients:')} ${len(c.group.recipients_sms(sender=c.user))}</span>

        <form method='post' action="${url(controller='group', action='send_sms', id=group.group_id)}">
            <input type="hidden" name="current_url" value="${url.current()}" />
            ${h.input_area('sms_message', '', value=('' if c.user.can_send_sms(group) else _('You do not have enough SMS credits to send a message to this group.')), cols=35, disabled=not c.user.can_send_sms(group))}
            %if not c.group.recipients_sms(sender=c.user):
              <div class="error-container">
                <span class="error-message">${_('No one in this group has confirmed their phone numbers.')}</span>
              </div>
            %endif

            %if c.user.can_send_sms(group):
              <div style="padding-top: 4px; float: left">
                ${h.input_submit(_('Send'))}
              </div>
              <div class="character-counter">
                  <span id="sms_message_symbols">140</span> / <span id="sms_messages_num">1</span>
              </div>
            %endif

            <div class="cost">
              <span class="cost-header">${_("Cost:")}</span>
              <span id="sms_message_credits">${len(c.group.recipients_sms(sender=c.user))}</span> ${_('SMS credits')}
              <img style="margin-bottom: -3px" src="/images/details/icon_question.png" class="tooltip " alt="${_('One SMS credit allows you to send one SMS message to a single recipient. When sending a message to a group, one credit is charged for every recipient.')}">
            </div>
            <div class="clear-both"></div>
        </form>

        <script>
        //<![CDATA[
            $(document).ready(function() {
                $('textarea#sms_message').keyup(function() {
                  var el = $('#sms_message')[0];
                  var s = el.value;
                  var ascii = true;
                  for (var i = 0; i < s.length; i++) {
                      var c = s.charCodeAt(i);
                      if (c > 127) {
                          ascii = false;
                          break;
                      }
                  }
                  var n_recipients = ${len(c.group.recipients_sms(sender=c.user))};
                  var text_length = s.length;

                  // Please keep math in sync with Python controller code.
                  // -----
                  var msg_length = text_length * (ascii ? 1 : 2);
                  if (msg_length <= 140) {
                      msgs = 1;
                  } else {
                      msgs = 1 + Math.floor((msg_length - 1) / 134);
                  }
                  var cost = n_recipients * msgs;
                  // -----

                  $('#sms_messages_num').text(msgs);
                  $('#sms_message_credits').text(cost);

                  var chars_remaining;
                  if (msg_length <= 140) {
                      chars_remaining = (140 - msg_length);
                  } else {
                      chars_remaining = 134 - (msg_length % 134)
                  }
                  if (!ascii)
                      chars_remaining = chars_remaining / 2;
                  $('#sms_message_symbols').text(chars_remaining);
                });
            });
        //]]>
        </script>
    </div>

    <div class="clear-left"></div>

    <div class="phone-message-block">
      <div class="block-head">
        ${_('Send a message from your phone!')}
        ##<img style="margin-bottom: -3px" src="/images/details/icon_question.png" class="tooltip " alt="${_('')}">
      </div>

      <div>
        ${_('You can send a message to your group directly from your phone. The message costs <strong>2 Lt</strong>, which pays for the delivery of the message to all recipients (your SMS credits will not be charged). Send the following text to number %(phone)s:') % dict(phone=c.pylons_config.get('fortumo.phone_number', '1337')) |n}
      </div>

      <div class="group-sms-content">
        TXT ${c.pylons_config.get('fortumo.group_message.code')} ${c.group.group_id} Your&nbsp;text</div>
      </div>

      <div class="clear-left"></div>

  </%self:uportlet>
</%def>
