<%inherit file="/ubase-nomenu.mako" />

<div id="sign-in-area">
  <h1>Sign up to join your university's social network or create it yourself</h1>
  <form id="sign-up-form" method="POST" action="${url('start_registration')}">
	<div class="error"><span>Your email adress is not valid</span></div>
	<fieldset id="register-fieldset">
      <input type="text" value="" name="email" id="email" class="email-input" />
      ${h.input_submit(_('Sign Up'))}
	</fieldset>
	<div class="notice"> Only people with a verified university / college email address can join your network </div>
  </form>
</div>
<div id="feature-area">
  <div class="column" id="social-discussions">
	<h1>Social discussions about course materials between students and teachers</h1>
	<p>Ututi lets You create a social network for Your university. Here You will find online groups, teachers profiles and course pages - a tool to share information and build your online community.<p>
  </div>
  <div class="column" id="network">
	<h1>Private social network for your university or college</h1>
	<p>Ututi lets You create a social network for Your university. Here You will find online groups, teachers profiles and course pages - a tool to share information and build your online community.<p>
  </div>
  <div class="column" id="teachers-profile">
	<h1>Easy to use personal websites for teachers</h1>
	<p>Teachers can create their website, share course materials and communicate with their students at Ututi. And they can do it easily.<p>
  </div>
</div>
<div class="center">
  <button id="learn-more" name="about">Learn more about Ututi</button>
</div>
