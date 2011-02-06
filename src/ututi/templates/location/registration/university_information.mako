<%inherit file="/base.mako" />

<h1>University information</h1>

<div class="text">You are registered to <strong>${c.location.title}</strong> network.</div>

<form id="registration_form" method="post" action="${c.location.url(action='register')}">
  <input type="hidden" name="step" value="step1" />
  <input type="hidden" name="email" value="${'%(email)s' % dict(email=email)}" />
  ${h.input_submit(_('Next'))}
</form>
