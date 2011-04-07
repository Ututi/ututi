<%inherit file="/profile/edit.mako" />
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<form method="post" action="${url(controller='profile', action='update_contacts')}"
      id="contacts_form" class="new-style-form">

  <h1 class='page-title'>${_("Contacts")}:</h1>

  <fieldset>

    ## GADU GADU

    %if c.gg_enabled:
      <div>
        ${h.input_line('gadugadu_uin', _('Your GG number'))}

          %if c.user.gadugadu_uin:
              %if not c.user.gadugadu_confirmed:
                <span class="field-status">${_('GG number is not confirmed')}</span>
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
                <span class="field-status confirmed">${_('GG number is confirmed')}</span>
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

    <%
    if c.user.phone_number and c.user.phone_confirmed:
        phone_help = None
    else:
        phone_help = _('Use international format, +XXXXXXXXXXX')
    %>

    ${h.input_line('phone_number', _('Mobile phone number'), help_text=phone_help)}

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
      <span class="field-status confirmed">${_('Email is confirmed')}</span>
    %else:
      ${h.input_line('email', _('Your email address'),
                     right_next= h.input_submit_text_button(_('Get confirmation email'), name='confirm_email'))}
      <span class="field-status">${_('Email is not confirmed')}</span>
    %endif

    ## GOOGLE AND FACEBOOK

    <div class="formField">
      <span class="labelText">${_("Link with Google and Facebook")}</span>
      <div id="google-and-facebook-buttons">
        %if not c.user.openid:
          <a id="google-link-button" href="${url(controller='profile', action='link_google')}">
            ${h.image('/img/google-button.png', alt=_('Link Google'))}
          </a>
        %else:
          <a id="google-unlink-button" href="${url(controller='profile', action='unlink_google')}">
            ${h.image('/img/google-button.png', alt=_('Unlink Google'))}
          </a>
        %endif

        %if not c.user.facebook_id:
          <a id="fb-link-button" href="#link-facebook">
            ${h.image('/img/facebook-button.png', alt=_('Link Facebook'))}
          </a>
        %else:
          <a id="fb-unlink-button" href="${url(controller='profile', action='unlink_facebook')}">
            ${h.image('/img/facebook-button.png', alt=_('Unlink Facebook'))}
          </a>
        %endif
      </div>
      <span class="helpText" style="clear:both">${_("Click the buttons to link or unlink your profile with Google and/or Facebook")}</span>
    </div>

    ${h.input_submit(name='update_contacts', class_='btnMedium')}

  </fieldset>
</form>

${init_facebook()}
<script>
  $(document).ready(function() {
    $('#fb-link-button').click(function() {
        // attempt to login FB
        FB.login(function(response) {
            if (response.session && response.perms) {
                // user is logged in and granted some permissions.
                // perms is a comma separated list of granted permissions
                window.location = '${url(controller='profile', action='link_facebook')}';
            }
        }, {perms:'email'});

        return false;
    });
  });
</script>
