<%inherit file="/prebase.mako" />

<%def name="body_class()">frontpage</%def>

<div id="sign-up">
  <div id="sign-up-inner">
    <div id="sign-in-area">
      <h1>${_("Sign up to join your university's social network or create it yourself")}</h1>
      <form id="sign-up-form" class="light" method="POST" action="${url(controller='home', action='register')}">
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
      ${h.button_to(_("Learn more"), '/features', id="learn-more", method='GET')}
    </div>
  </div>
</div>

<div id="about">
  <div id="about-inner" class="clearfix">
    <div id="features">
      <h2>${_("What is Ututi?")}</h2>
      <div class="feature" id="social-network">
        <h3>${_("Private social networks for universities.")}</h3>
        <p>${_("Ututi is a platform for creating academical social networks. It helps engage your students and teachers and improve the quality of your studies.")}</p>
      </div>
      <div class="feature" id="discussions">
        <h3>${_("Social discussions about course material between students and teachers.")}</h3>
        <p>${_("Students and teachers can discuss course material, academical matters and university life in a modern way.")}</p>
      </div>
      <div class="feature" id="personal-websites">
        <h3>${_("Course material publishing.")}</h3>
        <p>${_("Teachers can create areas for course information where students will be able to access, share and comment study materials.")}</p>
      </div>
    </div>
    <div id="using-ututi">
      <h2>${_("Using Ututi:")}</h2>
      <div class="university">
        <div class="uni-logo"><img src="${url('/img/icons.com/universities/MIF_logo.png')}" alt="VU MIF logo" title="Department of Mathematics and Informatics" /></div>
        <div class="strong"><a href="${url('/school/vu/mif')}">Vilnius University - Department of Mathematics and Informatics</a></div>
      </div>
      <div class="university">
        <div class="uni-logo"><img src="${url('/img/icons.com/universities/VU_logo.png')}" alt="VU logo" title="Vilnius university" /></div>
        <div class="strong" style="padding-top: 15px;"><a href="${url('/school/vu')}">Vilnius University</a></div>
      </div>
      <div class="university">
        <div class="uni-logo"><img src="${url('/img/icons.com/universities/LSMU_logo.png')}" alt="LSMU logo" title="Department of Mathematics and Informatics" /></div>
        <div class="strong" style="padding-top: 5px;"><a href="${url('/school/lsmu')}">Lithuanian University of Health Sciences</a></div>
      </div>
      <div class="university">
        <div class="uni-logo"><img src="${url('/img/icons.com/universities/VPU_logo.png')}" alt="VPU logo" title="Vilnius Pedagogical University" /></div>
        <div class="strong" style="padding-top: 10px;"><a href="${url('/school/vpu')}">Vilnius Pedagogical University</a></div>
      </div>
      <div class="more">${h.link_to(_('More'), url(controller='search', action='browse'))}</a></div>
    </div>
  </div>
</div>
