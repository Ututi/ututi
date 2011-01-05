<%inherit file="/ubase.mako" />

<div id="teacher-registration-page">
  <div class="two-panel-layout with-right-panel">
    <div class="left-panel">
      <h1 class="page-title">${_("Register as teacher:")}</h1>
      <form id="teacher_registration_form" method="post" action="${url.current(action='register')}" class="new-style-form">
        <fieldset>
          ${h.input_line('fullname', _('Full name'))}
          ${h.input_line('email', _('Email'), 
                         help_text=_("Please enter your university email. That way it will be easier to verify your identity."))}
          ${h.input_psw('new_password', _('Password'))}
          <div style="margin-top: 10px;">
          <label><input class="checkbox" checked="checked" type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}" rel="nofollow">${_('terms of use')}</a></label>
          </div>
          <form:error name="agree" />
            ${h.input_submit(_('Register'), class_='btnMedium')}
          <div class="formField">
            <p>${_("Register using your Google or Facebook account")}</p>
            <div id="google-and-facebook-buttons">
              <a id="google-link-button" href="${url(controller='federation', action='google_register', u_type='teacher')}">
                ${h.image('/img/google-button.png', alt=_('Log in using Google'))}
              </a>
              <a id="fb-link-button" href="#login-using-facebook">
                ${h.image('/img/facebook-button.png', alt=_('Log in using Facebook'))}
              </a>
            </div>
          </div>
        </fieldset>
      </form>
      <script type="text/javascript">
        $(document).ready(function() {
          $('#fb-link-button').click(function() {
              // attempt to login FB
              FB.login(function(response) {
                  if (response.session && response.perms) {
                      // user is logged in and granted some permissions.
                      // perms is a comma separated list of granted permissions
                      show_loading_message();
                      window.location = '${url(controller='federation', action='facebook_login', u_type='teacher')}';
                  }
              }, {perms:'email'});

              return false;
          });
        });
      </script>
    </div>
    <div class="right-panel">
      <h1 class="page-title">${_("Advantages of a teacher's profile:")}</h1>
      <ul class="feature-list">
        <li class="teacher-profile">
          <strong>${_("Teacher profile")}</strong>
          - ${_("submit your CV, thoughts, biography and academic papers.")}
        </li>
        <li class="file-sharing">
          <strong>${_("Course material sharing")}</strong>
          - ${_("upload and share course material with students of your class, university or the entire world.")}
        </li>
        <li class="contact-groups">
          <strong>${_("Direct messaging")}</strong>
          - ${_("create a private dialog with one or multiple students or groups.")}
        </li>
        <li class="sms">
          <strong>${_("SMS")}</strong>
          - ${_("send SMSs to your groups or friends. Get notifications and updates to your cell phone.")}
        </li>
      </ul>
    </div>
  </div>
</div>
