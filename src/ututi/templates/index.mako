<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<div class="block-content">
  <h1>Log in</h1>
  <form method="POST" id="login_form" action="/login">
    <table>
      <tr>
        <td>
          <label for="username">Username:</label>
        </td>
        <td>
          <input type="text" size="20" id="username" name="username" />
        </td>
      </tr>
      <tr>
        <td>
          <label for="password">Password:</label>
        </td>
        <td>
          <input type="password" size="20" name="password" id="password" />
        </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>
          <div class="formControls">
            <input class="login" type="submit" name="join" value="Login" />
            <a href="#"
               onclick="jq('#login_form').hide(); jq('#registration_form').show(); return false;">Register</a>
          </div>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <div class="message">
            If you forgot your password you can restore it by clicking <a href="mail_password_form?userid">here</a>.
          </div>
        </td>
      </tr>
    </table>
  </form>
</div>
