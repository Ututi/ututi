<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Reset your password')}</h1>

<form method="post" action="${url(controller='home', action='recovery', key=c.key)}">
  <div class="form-field">
    <input type="hidden" name="recovery_key" value="${c.key}"/>
    <label for="new_password">
      ${_('Enter Your new password.')}
    </label>
    <input type="password" size="60" name="new_password" id="new_password"/>
  </div>
  <div class="form-field">
    <label for="repeat_password">
      ${_('Repeat Your new password.')}
    </label>
    <input type="password" size="60" name="repeat_password" id="repeat_password"/>
  </div>

  <div class="form-field">
    <span class="btn">
      <input type="submit" value="${_('Change password')}"/>
    </span>
  </div>
</form>
