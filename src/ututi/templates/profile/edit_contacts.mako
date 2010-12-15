<%inherit file="/profile/edit.mako" />

<form method="post" action="${url(controller='profile', action='update_contacts')}"
      id="contacts_form" class="new-style-form">

  <h1 class='pageTitle'>${_("Contacts")}:</h1>

  <fieldset>

    ## GADU GADU

    %if c.gg_enabled:
      <div>
        ${h.input_line('gadugadu_uin', _('Your GG number'))}

          %if c.user.gadugadu_uin:
              %if not c.user.gadugadu_confirmed:
                <div class="field-status">${_('GG number is not confirmed')}</div>
                ${h.input_line('gadugadu_confirmation_key',
                               _("Enter the code that you have received in your GG"),
                               help_text=h.literal(_("""

                      Should you not have received the code, please press "Send code again".
                      Also don't forget to add Ututi (<a href="gg:5437377">5437377</a>) to your friends!""")),

                               right_next=h.input_submit(_('Submit code'), name='confirm_gadugadu') + \
                                          h.input_submit_text_button(_('Send code again'), name='resend_gadugadu_code')
                               )}
              %else:
                <input type="hidden"  name="gadugadu_confirmation_key" />
                <div class="field-status confirmed"><div>${_('GG number is confirmed')}</div></div>
                <div class="no-break">
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

    ${h.input_line('phone_number', _('Mobile phone number'))}

    %if c.user.phone_number:
      %if not c.user.phone_confirmed:
        <span class="field-status">${_('Number is not confirmed')}</span>
        ${h.input_line('phone_confirmation_key',
                       _("Enter the code that you have received by SMS"),
                       help_text=_('Should you not have received the code, please press "Send code again"'),
                       right_next=h.input_submit(_('Submit code'), name='confirm_phone') + \
                                  h.input_submit_text_button(_('Send code again'), name='resend_phone_code')
                       )}
      %else:
        <span class="field-status confirmed">${_('Number is confirmed')}</span>
        <input type="hidden"  name="phone_confirmation_key" />
      %endif
    %else:
      <input type="hidden" name="phone_confirmation_key" />
    %endif

    ## E-MAIL

    %if c.user.isConfirmed:
      ${h.input_line('email', _('Your email address'))}
      <div class="field-status confirmed"><div>${_('Email is confirmed')}</div></div>
    %else:
      ${h.input_line('email', _('Your email address'),
                     right_next= h.input_submit_text_button(_('Get confirmation email'), name='confirm_email'))}
      <div class="field-status">${_('Email is not confirmed')}</div>
    %endif

    ${h.input_submit(name='update_contacts', class_='btnMedium')}

  </fieldset>
</form>

<div style="margin-top: 30px">
  %if c.user.openid:
    ${_('Unlink')}
    <a href="${url(controller='profile', action='unlink_google')}">
      ${h.image('/img/google-logo.gif', alt='Google', class_='google-login')}
    </a>
  %else:
    ${_('Link to')}
    <a href="${url(controller='profile', action='link_google')}">
      ${h.image('/img/google-logo.gif', alt='Google', class_='google-login')}
    </a>
  %endif

  <div id="fb-root"></div>
  <script src="http://connect.facebook.net/lt_LT/all.js"></script>
  <script>
    FB.init({appId: '${c.facebook_app_id}', status: true,
        cookie: true, xfbml: true});
  </script>
  %if c.user.facebook_id:
    ${h.button_to(_('Unlink'), url(controller='profile', action='unlink_facebook'))}
    ${_('Unlink')}
    <fb:login-button perms="email"
      onlogin="window.location = '${url(controller='profile', action='unlink_facebook')}'"
     >${_('Connect')}</fb:login-button>
  %else:
    ${_('Link to')}
    <fb:login-button perms="email"
      onlogin="window.location = '${url(controller='profile', action='link_facebook')}'"
     >${_('Connect')}</fb:login-button>
  %endif
</div>
