<%inherit file="/base.mako" />

<h1>Email approval</h1>

%if hasattr(c, 'error_message'):
  <p class="error-message">
    ${c.error_message}
  </p>
%endif

<div id="confirmation-instruction">
  <p>${_('Please enter the confirmation code, or continue registration by following the link that was sent to your email.')}</p>
</div>
