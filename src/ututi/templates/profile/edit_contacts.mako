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
    ${_("Edit your contact information below. Some fields may require confirmation.")}
  </p>
</div>

<form method="post" action="${url(controller='profile', action='update_contacts')}"
      id="contacts-form">

  ## ADDRESS (FOR TEACHERS)

  %if c.user.is_teacher:
    ${h.input_line('work_address', _('Work address'))}
  %endif

  ## PHONE NUMBER

  <%
  if c.user.phone_number:
      phone_help = None
  else:
      phone_help = _('Use international format, +XXXXXXXXXXX')
  %>

  ${h.input_line('phone_number', _('Mobile phone number'), help_text=phone_help)}

  ## E-MAIL

  %if c.user.isConfirmed:
    ${h.input_line('email', _('Your email address'))}
    <p class="field-status confirmed">${_('Email is confirmed')}</p>
    %if c.user.is_teacher:
    <div style="margin-bottom:20px">
      <label for="email-is-public">
        <input type="checkbox" name="email_is_public" class="checkbox"
               id="email-is-public" />
        ${_('Show my email to unregistered users.')}
      </label>
    </div>
    %endif
  %else:
    ${h.input_line('email', _('Your email address'),
                   right_next= h.input_submit_text_button(_('Get confirmation email'), name='confirm_email'))}
    <p class="field-status">${_('Email is not confirmed')}</p>
  %endif

  ## WEB SITE URL

  ${h.input_line('site_url', _('Address of your website or blog'))}

  ${h.input_submit(name='update_contacts')}
</form>
