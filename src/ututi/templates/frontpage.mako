<%inherit file="/prebase.mako" />

<%def name="body_class()">frontpage</%def>

<div id="sign-up">
  <div id="sign-up-inner">
    <div id="sign-in-area">
      <h1>${_("Sign up to join your university's social network or create it yourself")}</h1>
      <form id="sign-up-form" method="POST" action="${url(controller='home', action='register')}">
        <div class="message-container">
          <form:error name="email" format="raw" />
        </div>
        <fieldset id="register-fieldset">
          <label>${_("Enter your academic email")}</label>
          <input type="text" value="" name="email" id="email" class="email-input" />
          ${h.input_submit(_('Sign Up'))}
        </fieldset>
        <div class="notice">
          ${_("Only people with a verified university / college email address can join your network.")}
        </div>
        <script type="text/javascript">
          $(document).ready(function(){$("#sign-up-form label").labelOver('over');});
        </script>
      </form>
      ${h.button_to(_("Learn more"), '#', id="learn-more", class_="dark", method='GET')}
    </div>
  </div>
</div>

<div id="about">
  <div id="about-inner" class="clearfix">
    <div id="features">
      <h2>${_("What is Ututi?")}</h1>
      <div class="feature" id="discussions">
        <p><strong>${_("Social discussions about course material between students and teachers.")}</strong></p>
        <p>${_("Students and teachers can discuss course material, academical matters and university life in modern way.")}</p>
      </div>
      <div class="feature" id="social-network">
        <p><strong>${_("Strong sentence.")}</strong></p>
        <p>${_("Explaining note.")}</p>
      </div>
      <div class="feature" id="personal-websites">
        <p><strong>${_("Strong sentence.")}</strong></p>
        <p>${_("Explaining note.")}</p>
      </div>
    </div>
    <div id="using-ututi">
      <h2>${_("Using Ututi:")}</h1>
    </div>
  </div>
</div>
