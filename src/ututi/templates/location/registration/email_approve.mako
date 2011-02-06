<%inherit file="/base.mako" />

<h1>Email approval</h1>

<div class="text">${_('We need to approve if you are owner of this email. You have received a confirmation code to %(email)s.') % dict(email=email)}</div>
