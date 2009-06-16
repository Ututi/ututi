<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<div class="block-content">
  <h1>Log in</h1>
  <form method="POST" id="login_form" action="/dologin">
    %if request.GET.get('came_from'):
       <input type="hidden" name="came_from" value="${request.GET.get('came_from')}" />
    %endif
    <table>
      <tr>
        <td>
          <label for="login">Email:</label>
        </td>
        <td>
          <input type="text" size="20" id="login" name="login" />
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


  <form id="registration_form" method="POST" action="/register">
    <table>
      <tr>
        <td><label for="fullname">Fullname</label></td>
        <td><input type="text" id="fullname" name="fullname" size="20"/></td>
      </tr>
      <tr>
        <td><label for="email">Email</label></td>
        <td><input type="text" id="email" name="email" size="20"/></td>
      </tr>
      <tr>
        <td><label for="new_password">Password</label></td>
        <td><input type="password" id="new_password" name="new_password" size="20"/></td>
      </tr>
      <tr>
        <td><label for="repeat_password">Repeat password</label></td>
        <td><input type="password" id="repeat_password" name="repeat_password" size="20"/></td>
      </tr>
      <tr>
        <td colspan="2"><input type="submit" value="Register"/></td>
      </tr>
    </table>

  </form>
</div>
