<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Reset your password')}</h1>

<form method="post" action="${url(controller='home', action='recovery', key=c.key)}" class="fullForm">
  <div class="form-field">
    <input type="hidden" name="recovery_key" value="${c.key}"/>
    <label for="new_password">
      ${_('Enter Your new password.')}
    </label>
    <form:error name='new_password' />
    <div class="textField input-line"><div>
        <input type="password" size="30" name="new_password" id="new_password" class="line"/>
        <span class="edge"></span>
    </div></div>
  </div>
  <div class="form-field">
    <label for="repeat_password">
      ${_('Repeat Your new password.')}
    </label>
    <form:error name='repeat_password' />
    <div class="textField input-line"><div>
        <input type="password" size="30" name="repeat_password" id="repeat_password" class="line"/>
        <span class="edge"></span>
    </div></div>
  </div>

  ${h.input_submit(_('Change password'))}
</form>
