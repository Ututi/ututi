<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Recover your password')}</h1>


<form method="post" action="${url(controller='home', action='pswrecovery')}">
  <div class="form-field">
    <label for="email">
      ${_('Enter your email:')}
    </label>
    <input type="text" size="60" name="email" id="email"/>
  </div>
  <div class="form-field">
    <span class="btn">
      <input type="submit" value="${_('Recover password')}"/>
    </span>
  </div>
</form>
