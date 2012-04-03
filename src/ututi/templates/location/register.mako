<%inherit file="/location/base.mako" />

<%def name="pagetitle()">
  ${_("Join as student")}
</%def>

<form id="sign-up-form" method="POST" action="${c.location.url(action='register')}">
  <fieldset id="register-fieldset">
    <label for="email">
    %if c.location.public:
      ${_("Enter your email")}:
    %else:
      ${_("Enter your academic email")}:
    %endif
    </label>
    <input type="text" value="" name="email" id="email" class="email-input" /><br /><br />
    ${h.input_submit(_('Sign Up'))}
    %if not c.location.public:
    <div class="notice">
      ${_("Only people with a verified university / college email address can join your network.")}
    </div>
    %endif
  </fieldset>
</form>

<div class="feature-box simple">
  <div class="title">
    ${_("Ututi student accounts:")}
  </div>
  <div class="clearfix">
    <div class="feature icon-group">
      ${h.literal(_("<strong>Join or create your group</strong> for easy communication and collaboration with your classmates."))}
    </div>
    <div class="feature icon-subject">
      ${h.literal(_("<strong>Start following courses</strong> that interest you. Find course material and receive notifications about course related updates."))}
    </div>
  </div>
  <div class="clearfix">
    <div class="feature icon-file-upload">
      ${h.literal(_("<strong>Upload files</strong> to share them with your classmates. Files uploaded to course catalog will be available to everyone who is interested in the subject."))}
    </div>
    <div class="feature icon-wiki">
      ${h.literal(_("<strong>Create wiki notes</strong> and edit them together with other people on the network. You can even take notes to Ututi during your lectures."))}
    </div>
  </div>
</div>
