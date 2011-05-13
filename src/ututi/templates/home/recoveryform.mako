<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Recover your password')}</h1>


<form method="post" action="${url(controller='home', action='pswrecovery')}" class="fullForm">
  ${h.input_line('email', _('Enter your email:'))}
  ${h.input_submit(_('Recover password'))}
</form>
