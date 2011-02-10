<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("Email approval")}</%def>

%if hasattr(c, 'error_message'):
  <p class="error-message">
    ${c.error_message}
  </p>
%endif

<div id="confirmation-instruction">
  <p>
    ${_('We need to approve that you are the owner of this email address.')}
    ${_('You have received a confirmation code to %(email_address)s.') % dict(email_address=c.email)}
  </p>
  <p>
    ${_('Did not get the confirmation code? Press "Send again" button.')}
  </p>
</div>

<form action="${url(controller='registration', action='resend_code')}" method="POST">
  ${h.input_hidden('email', c.email)}
  ${h.input_submit(_("Send again"))}
</form>
