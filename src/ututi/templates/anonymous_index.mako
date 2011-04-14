<%inherit file="/prebase.mako" />

<%def name="body_class()">frontpage</%def>

<div id="sign-in-area">
  <h1>${_("Sign up to join your university's social network or create it yourself")}</h1>
  <form id="sign-up-form" method="POST" action="${url(controller='home', action='register')}">
    <form:error name="email" format="raw" />
    <fieldset id="register-fieldset">
      <input type="text" value="" name="email" id="email" class="email-input" />
      ${h.input_submit(_('Sign Up'))}
    </fieldset>
    <div class="notice">${_("Only people with a verified university / college email address can join your network.")}</div>
  </form>
</div>
<div id="features" class="clearfix">
  <div class="column" id="social-discussions">
    <h1>${_("Social discussions between students and teachers")}</h1>
    <p>${_("On Ututi students and teachers can discuss course material, academical matters and university life in a modern way.")}</p>
  </div>
  <div class="column" id="network">
    <h1>${_("Private social network for your university or college")}</h1>
    <p>${_("Ututi lets You create a social network for Your university. Here You will find online groups, teachers profiles and course pages - a tool to share information and build your online community.")}</p>
  </div>
  <div class="column" id="teachers-profile">
    <h1>${_("Easy to use teachers accounts")}</h1>
    <p>${_("Teachers can create their website, share course materials and communicate with their students at Ututi. And they can do it easily.")}</p>
  </div>
</div>
<button id="learn-more" name="about">Learn more about Ututi</button>
