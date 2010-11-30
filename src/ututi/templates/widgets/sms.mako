<%namespace file="/sections/content_snippets.mako" import="tooltip" />

<%def name="sms_widget(user=None, group=None)">
<%
    if user is None:
        user = c.user
    if group is None:
        group = c.group
%>
<div class="sms-widget">
<div class="credits-remaining">
  <div class="sms-intro">
    ${_('Send an SMS message to all your classmates. The service is paid by SMS credits (1 credit = 1 SMS message to one person). The cost of an SMS message depends on the number of members in the group.')}
  </div>

  <div class="credit-info">
    <span class="credits-header">${_('Credits left:')}</span>
    <span class="num-credits-remaining ${'shortage' if not c.user.can_send_sms(group) else ''}">${user.sms_messages_remaining}</span>
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
        ${_('Send an SMS message to number <span style="font-size: 14px">%(phone)s</span> with the following content:') % dict(phone=c.pylons_config.get('fortumo.personal_sms_credits.number', '1337')) |n}
      </div>
      <div class="sms-content">TXT ${c.pylons_config.get('fortumo.personal_sms_credits.code')} ${group.group_id}</div>
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
        %for credits, amount, form in group.sms_payments():
        <tr>
          <td>
            <form action="${form.action}" method="POST" class="sms-form">
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
  <% recipients = group.recipients_sms(sender=c.user) %>
  <span>${_('Message text:')}</span>
  <span class="recipients">${_('Recipients:')} ${len(recipients)}</span>

  <form id="sms-portlet-form" method='post' action="${url(controller='group', action='send_sms', id=group.group_id)}">
    <input type="hidden" name="current_url" value="${url.current()}" />

    %if user.can_send_sms(group):
      ${h.input_area('sms_message', '', value="\n\n\n-- %s" % user.fullname, cols=35)}
    %else:
      ${h.input_area('sms_message', '', _('You do not have enough SMS credits to send a message to this group.'), cols=35, disabled=True)}
    %endif

    %if not recipients:
    <div class="error-container">
      <span class="error-message">${_('No one in this group has confirmed their phone numbers.')}</span>
    </div>
    %endif

    %if user.can_send_sms(group):
    <div style="padding-top: 4px; float: left">
      ${h.input_submit(_('Send'), class_='btn action_submit')}
    </div>
    <div class="character-counter">
      <span id="sms_message_symbols">140</span> / <span id="sms_messages_num">1</span>
    </div>
    %endif

    <div class="cost">
      <span class="cost-header">${_("Cost:")}</span>
      <span id="sms_message_credits">${len(recipients)}</span> ${_('SMS credits')}
      ${tooltip(_("one SMS credit allows you to send one SMS message to a single recipient. "
                  "When sending a message to a group, one credit is charged for every recipient."),
                style="margin-bottom: -3px")}
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
                  var n_recipients = ${len(recipients)};
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
  </div>

  <div>
    ${_('You can send a message to your group directly from your phone. The message costs <strong>2 Lt</strong>, which pays for the delivery of the message to all recipients (your SMS credits will not be charged). Send the following text to number %(phone)s:') % dict(phone=c.pylons_config.get('fortumo.group_message.number', '1337')) |n}
  </div>

  <div class="group-sms-content">
    TXT ${c.pylons_config.get('fortumo.group_message.code')} ${group.group_id} ${_('Your text')}</div>
</div>
</div>
</%def>
