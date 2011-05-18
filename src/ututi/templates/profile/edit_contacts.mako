<%inherit file="/profile/edit_base.mako" />

<%def name="css()">
  ${parent.css()}
  #contacts-form .formField {
      margin-bottom: 10px;
  }
  #contacts-form .field-status {
      margin-top: -8px; /* cancel fromField bottom margin */
      margin-bottom: 8px;
      /* should attract attention */
      color: #d45500;
      font-size: 10px;
  }

  #contacts-form .field-status.confirmed {
      /* should bring peace  */
      color: #666;
      background: url("/img/icons/tick_10.png") no-repeat left center;
      padding-left: 12px;
      font-style: italic;
  }

</%def>

<div class="explanation-post-header">
  <h2>${_('Contact information')}</h2>
  <p class="tip">
    ${_("Be findable.")}
  </p>
</div>

<form method="post" action="${url(controller='profile', action='update_contacts')}"
      id="contacts-form">

  ## GADU GADU

  %if c.gg_enabled:
    <div>
      ${h.input_line('gadugadu_uin', _('Your GG number'))}

        %if c.user.gadugadu_uin:
            %if not c.user.gadugadu_confirmed:
              <p class="field-status">${_('GG number is not confirmed')}</p>
              ${h.input_line('gadugadu_confirmation_key',
                             _("Enter the code that you have received in your GG"),
                             help_text=h.literal(_("""

                    Should you not have received the code, please press "Send code again".
                    Also don't forget to add Ututi (<a href="gg:5437377">5437377</a>) to your friends!""")),

                             right_next=h.input_submit(_('Submit code'), name='confirm_gadugadu', class_='dark inline') + \
                                        h.input_submit_text_button(_('Send code again'), name='resend_gadugadu_code')
                             )}
            %else:
              <input type="hidden"  name="gadugadu_confirmation_key" />
              <p class="field-status confirmed">${_('GG number is confirmed')}</p>
              <div class="formField">
                <label for="gadugadu_get_news">
                  <input type="checkbox" name="gadugadu_get_news" class="checkbox"
                         id="gadugadu_get_news" class="line" />

                  ${_('Receive news into gg')}
                </label>
              </div>
            %endif
        %else:
          <input type="hidden" name="gadugadu_confirmation_key" />
        %endif
    </div>
  %else:
    <input type="hidden" name="gadugadu_uin" />
    <input type="hidden" name="gadugadu_confirmation_key" />
  %endif

  ## PHONE NUMBER

  <%
  if c.user.phone_number and c.user.phone_confirmed:
      phone_help = None
  else:
      phone_help = _('Use international format, +XXXXXXXXXXX')
  %>

  ${h.input_line('phone_number', _('Mobile phone number'), help_text=phone_help)}

  %if c.user.phone_number:
    %if not c.user.phone_confirmed:
      <p class="field-status">${_('Number is not confirmed')}</p>
      ${h.input_line('phone_confirmation_key',
                     _("Enter the code that you have received by SMS"),
                     help_text=_('Should you not have received the code, please press "Send code again"'),
                     right_next=h.input_submit(_('Submit code'), name='confirm_phone', class_='dark inline') + \
                                h.input_submit_text_button(_('Send code again'), name='resend_phone_code')
                     )}
    %else:
      <p class="field-status confirmed">${_('Number is confirmed')}</p>
      <input type="hidden"  name="phone_confirmation_key" />
    %endif
  %else:
    <input type="hidden" name="phone_confirmation_key" />
  %endif

  ## E-MAIL

  %if c.user.isConfirmed:
    ${h.input_line('email', _('Your email address'))}
    <p class="field-status confirmed">${_('Email is confirmed')}</p>
  %else:
    ${h.input_line('email', _('Your email address'),
                   right_next= h.input_submit_text_button(_('Get confirmation email'), name='confirm_email'))}
    <p class="field-status">${_('Email is not confirmed')}</p>
  %endif

  ## WEB SITE URL

  ${h.input_line('site_url', _('Address of your website or blog'))}

  ${h.input_submit(name='update_contacts')}
</form>
