<%inherit file="/location/base.mako" />

<%def name="pagetitle()">
  ${_("Join as teacher")}
</%def>

<form id="sign-up-form" method="POST" action="${c.location.url(action='register_teacher')}">
  <form:error name="email" format="raw" />
  <fieldset id="register-fieldset">
    <label for="email">${_("Enter your academic email")}</label>
    <input type="text" value="" name="email" id="email" class="email-input" />
    ${h.input_submit(_('Sign Up'))}
    <div class="notice">
      ${_("Only people with a verified university / college email address can join your network.")}
    </div>
  </fieldset>
  <script type="text/javascript">
    $(document).ready(function(){$("#sign-up-form label").labelOver('over');});
  </script>
</form>

<div class="feature-box simple">
  <div class="title">
    ${_("Ututi teacher accounts:")}
  </div>
  <div class="clearfix">
    <div class="feature icon-cv">
      ${h.literal(_("<strong>Fill in your biography</strong> to represent yourself to other members of your academic community."))}
    </div>
    <div class="feature icon-file-upload">
      ${h.literal(_("<strong>Upload course material.</strong> It will become immediately available to everyone who is following your course."))}
    </div>
  </div>
  <div class="clearfix">
    <div class="feature icon-publications">
      ${h.literal(_("<strong>Select and organize your publications</strong> that will be displayed on your Ututi profile page."))}
    </div>
    <div class="feature icon-email">
      ${h.literal(_("<strong>Contact your followers</strong> by sending group or private messages, or firing discussions on the course wall."))}
    </div>
  </div>
</div>
