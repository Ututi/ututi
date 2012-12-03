<%inherit file="/location/base.mako" />

<%def name="pagetitle()">
  ${c.subdepartment.title}
</%def>

<%def name="pageheader()">
  <div class="login-box">
    <div class="login-box-title">
      <div class="login-box-title-text">${_('Login')}</div>
      <div class="login-box-title-login-as-student" style="display: none;">${_('Login as a student')}</div>
      <div class="login-box-title-login-as-teacher" style="display: none;">${_('Login as a teacher')}</div>
      <div class="login-box-title-register-as-student" style="display: none;">${_('Register as a student')}</div>
      <div class="login-box-title-register-as-teacher" style="display: none;">${_('Register as a teacher')}</div>
      <hr />
    </div>

    <div class="login-box-content">
      <div class="login-box-content-buttons">
        <button type="button" id="i-am-a-student" class="student"><img src="${url('/img/student-icon.png')}" alt="${_('I am a student')}" class="icon" />${_('I am a student')}</button>
        <button type="button" id="i-am-a-teacher" class="teacher"><img src="${url('/img/teacher-icon.png')}" alt="${_('I am a teacher')}" class="icon" />${_('I am a teacher')}</button>
      </div>

      <div class="login-box-content-loginform">
        <form action="/login" method="post">
          <label for="email">${_('Email')}</label>
          <input class="university-email" type="text" id="email" name="username" />
          <label for="password">${_('Password')}</label>
          <input class="university-password" type="password" id="password" name="password" />
          <a href="/password" id="forgot_password">${_('Forgot password?')}</a>
          <div id="keep-me-logged-in">
            <input type="checkbox" checked="checked" name="remember">
            ${_('Keep me logged in')}
          </div>
          <input type="submit" class="orange" value="${_('Login')}" />
          <a href="${url(controller='home', action='index')}">${_('or register')}</a>
        </form>
      </div>

      <div class="login-box-content-registerform">
        <form action="${c.location.url()}/register" method="POST" id="sign-up-form" class="hide">
          <label for="email">${_('Email')}</label>
          <input class="university-email" type="text" id="email" name="email" required="required" />

          <input type="button" class="black back_to_login_button" value="${_('Login')}" />
          <input type="submit" class="orange" value="${_('Create an account')}" />
        </form>
        <form action="${c.location.url()}/register/teacher" method="POST" id="sign-up-form-teacher" class="hide">
          <label for="email">${_('Email')}</label>
          <input class="university-email" type="text" id="email" name="email" />
          <input type="button" class="orange back_to_login_button" value="${_('Login')}" />
          <a href="${url(controller='home', action='index')}">${_('or register')}</a>
        </form>

      </div>
    </div>
  </div>

  ${parent.pageheader()}

  <script>
      $(document).ready(function() {
          $('.login-box-content button').click(function() {
              var person = $(this).attr('class'); // teacher or student

              $('.login-box-title-text').hide();
              $('.login-box-title-login-as-' + person).show();

              $('.login-box-content-buttons').hide();
              $('.login-box-content-loginform').show();

              $('#create_account').click(function() {
                  $('.login-box-title-login-as-' + person).hide();
                  $('.login-box-title-register-as-' + person).show();

                  $('.login-box-content-loginform').hide();
                  $('.login-box-content-registerform').show();

                  if (person == 'student') {
                      $('#sign-up-form').show();
                  } else {
                      $('#sign-up-form-teacher').show();
                  }
              });

              $('.back_to_login_button').click(function() {
                  $('.login-box-content-registerform').hide();

                  if (person == 'student') {
                      $('#sign-up-form').hide();
                  } else {
                      $('#sign-up-form-teacher').hide();
                  }

                  $('.login-box-title-register-as-' + person).hide();
                  $('.login-box-title-login-as-' + person).show();

                  $('.login-box-content-loginform').show();
              });
          });
      });
  </script>
</%def>

<div class="subdepartment-description">
  ${h.literal(c.subdepartment.description)}
</div>
