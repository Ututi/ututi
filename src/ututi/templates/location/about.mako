<%inherit file="/location/base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
</%def>

<%def name="css()">
  ${parent.css()}

  .university-box {
    margin: 25px 0;
    padding: 10px 0;
  }

  .university-box .box-title {
    font-weight: bold;
    margin-bottom: 10px;
    float: left;
  }

  .university-box .create-link {
    float: right;
  }

  .university-box .university-entry {
    color: #666666;
    width: 50%;
    float: left;
    margin-top: 5px;
  }

  .university-entry .logo {
    float: left;
    margin-right: 7px;
    margin-top: 2px;
  }

  .university-entry .logo img {
    width: 30px;
    height: 30px;
  }

  .university-entry .title {
    font-weight: bold;
    color: #333333;
  }

  .university-entry ul.statistics li {
    display: inline-block;
    margin-right: 5px;
    min-width: 20px;    /* makes icons line up nicely in list */
  }

  h1.page-title {
    font-size: 22px;
    margin-bottom: 0px;
  }

  .sub-title {
    border-top: 1px solid #edf2f9;
    border-bottom: 1px solid #edf2f9;
    padding: 10px 0;
    margin-top: 12px;
    font-size: 11px;
    margin-bottom: 20px;
    float: left;
    width: 440px;
  }

  .about-box {
    border: solid 1px #ccc;
    margin: 5px 0;
    padding-left: 20px;
    padding-bottom: 10px;
    width:250px;
    float: right;
  }

  .about-box .feature {
    width: 215px;
    margin-top: 10px;
  }

  .login-box {
    float: right;
    margin: 7px 8px 0 0;
    padding: 10px;
    -moz-border-radius: 15px;
    border-radius: 15px;
    border: 1px solid #dfdfdf;
    -moz-box-shadow: 0 0 0 6px #f2f2f2;
    -webkit-box-shadow: 0 0 0 6px #f2f2f2;
    box-shadow: 0 0 0 6px #f2f2f2;
    width: 250px;
  }

  .login-box-title {
    background-color: #e3eaf4;
    -moz-border-radius: 5px;
    border-radius: 5px;
    height: 70px;

    background-image: linear-gradient(center 80px, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -o-linear-gradient(center 80px, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -moz-linear-gradient(center 80px, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -webkit-linear-gradient(center 80px, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -ms-linear-gradient(center 80px, #FFFFFF 0%, #E3EAF4 100%);

    background-image: -webkit-gradient(
	linear,
	left bottom,
	left top,
	color-stop(0, #FFFFFF),
	color-stop(1.0, #E3EAF4)
    );
  }

  .login-box-title-text {
    font-weight: bold;
    font-family: Arial,Verdana,sans-serif;
    font-size: 14px;
    padding: 20px 0 0 45px;
    color: #333333;
    text-shadow: 0px 0px 1px #ffffff;
    text-transform: uppercase;

    background-image: url('/img/login-arrow.png');
    background-repeat: no-repeat;
    background-position: 18px 20px;
  }

  .login-box-title hr {
    color: #eef2fa;
    border: 0;
    height: 1px;
    background: #eef2fa;
    margin-top: 20px;
    width: 100%;
  }

  .login-box .login-box-content {
    margin: 0 0 30px 0;
  }

  .login-box .login-box-content button {
    display: block;
    margin: 0 auto 25px auto;
    height: 50px;
    width: 190px;
    color: #ffffff;
    font-weight: bold;
    font-size: 14px;
    border: 1px solid #a0b0c8;

    background-image: linear-gradient(bottom, #728BAF 1%, #8EA2BF 60%);
    background-image: -o-linear-gradient(bottom, #728BAF 1%, #8EA2BF 60%);
    background-image: -moz-linear-gradient(bottom, #728BAF 1%, #8EA2BF 60%);
    background-image: -webkit-linear-gradient(bottom, #728BAF 1%, #8EA2BF 60%);
    background-image: -ms-linear-gradient(bottom, #728BAF 1%, #8EA2BF 60%);

    background-image: -webkit-gradient(
	linear,
	left bottom,
	left top,
	color-stop(0.01, #728BAF),
	color-stop(0.6, #8EA2BF)
);
  }

  .login-box .login-box-content img.icon {
    padding-right: 15px;
  }

  .login-box .login-box-content-buttons {
    margin-top: 30px;
  }

  .login-box-content-loginform {
    display: none;
  }

  .login-box-content-registerform {
    display: none;
  }

  .login-box-content-loginform, .login-box-content-registerform {
    width: 200px;
    margin: 0 auto;
  }

  .login-box-content-loginform label, 
  .login-box-content-registerform label {
    text-transform: uppercase;
    display: block;
    margin-bottom: 5px;
  }

  .login-box-content-loginform input[type=text], 
  .login-box-content-loginform input[type=password],
  .login-box-content-registerform input[type=text], 
  .login-box-content-registerform input[type=password] {
    width: 190px;
    border: 1px solid #b9b9b9;
    border-right: 2px solid #d6d6d6;
    border-bottom: 2px solid #d6d6d6;
    -moz-box-shadow: 0 0 0 2px #f2f2f2;
    -webkit-box-shadow: 0 0 0 2px #f2f2f2;
    box-shadow: 0 0 0 2px #f2f2f2;
  }

  #email {
    margin-bottom: 13px;
  }

  #forgot_password {
    font-size: 11px;
    display: block;
    margin-top: 2px;
  }

  #keep-me-logged-in {
    margin: 10px 0;
    font-size: 11px;
    color: #3D617A;
  }

  #keep-me-logged-in input {
    vertical-align: middle;
  }

  .login-box-content input[type=submit] {
    background-image: linear-gradient(bottom, #545454 0%, #6D6D6D 100%);
    background-image: -o-linear-gradient(bottom, #545454 0%, #6D6D6D 100%);
    background-image: -moz-linear-gradient(bottom, #545454 0%, #6D6D6D 100%);
    background-image: -webkit-linear-gradient(bottom, #545454 0%, #6D6D6D 100%);
    background-image: -ms-linear-gradient(bottom, #545454 0%, #6D6D6D 100%);

    background-image: -webkit-gradient(
	linear,
	left bottom,
	left top,
	color-stop(0, #545454),
	color-stop(1, #6D6D6D)
    );

    color: #ffffff;
    border: 1px solid #6d6d6d;
    font-size: 12px;
    font-weight: bold;
    font-family: Arial,Verdana,sans-serif;
    padding: 5px 10px;
    margin: 0 2px;
  }

  .login-box-content input[type=button] {
    color: #ffffff;
    margin: 0 2px;
    font-size: 12px;
    font-weight: bold;
    font-family: Arial,Verdana,sans-serif;
    padding: 5px 8px;
    border: 1px solid #f09252;

    background-image: linear-gradient(bottom, #EF843D 0%, #F2975B 100%);
    background-image: -o-linear-gradient(bottom, #EF843D 0%, #F2975B 100%);
    background-image: -moz-linear-gradient(bottom, #EF843D 0%, #F2975B 100%);
    background-image: -webkit-linear-gradient(bottom, #EF843D 0%, #F2975B 100%);
    background-image: -ms-linear-gradient(bottom, #EF843D 0%, #F2975B 100%);

    background-image: -webkit-gradient(
	linear,
	left bottom,
	left top,
	color-stop(0, #EF843D),
	color-stop(1, #F2975B)
    );
  }

  .login-box-content-loginform-buttons {
    text-align: center;
  }

</%def>

<%def name="university_entry(uni)">
<div class="university-entry clearfix">
  <div class="logo">
    <img src="${url(controller='structure', action='logo', id=uni['id'], width=30, height=30)}"
         alt="logo" />
  </div>
  <div class="title">
    <a href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 36)}</a>
  </div>
  <ul class="icon-list statistics">
    <li class="icon-subject"> ${uni['n_subjects']} </li>
    <li class="icon-group"> ${uni['n_groups']} </li>
    <li class="icon-file"> ${uni['n_files']} </li>
  </ul>
</div>
</%def>

<%def name="university_box(unis, title)">
%if unis:
<div class="university-box clearfix">
  <div class="clearfix">
    <h2 class="single-title">${title}</h2>
    %if h.check_crowds(['moderator']):
      <a class="create-link" href="${url(controller='structure', action='index')}">
        ${_("+ Add department")}
      </a>
    %endif
  </div>
  %for uni in unis:
    ${university_entry(uni)}
  %endfor
</div>
%endif
</%def>

<%def name="pageheader()">
  <div style="float: left;">
    <div style="float: left;">
      <h1 class="page-title">
        ${self.pagetitle()}
      </h1>
    </div>
    <div class="sub-title" style="clear: left;">
      ${h.literal(_('Welcome to the social network of %s!') % ('<a href="#" target="_self" onclick="window.open(document.URL, this.target)">%s</a>' % h.simple_declension(c.location.title, lang=c.lang)))} 
    </div>
  </div>

  <div class="login-box">
    <div class="login-box-title">
      <div class="login-box-title-text">Register or login</div>
      <hr />
    </div>

    <div class="login-box-content">
      <div class="login-box-content-buttons">
        <button type="button" class="student"><img src="/img/student-icon.png" alt="I am a student" class="icon" />I am a student</button>
        <button type="button" class="teacher"><img src="/img/teacher-icon.png" alt="I am a teacher" class="icon" />I am a teacher</button>
      </div>

      <div class="login-box-content-loginform">
        <form>
          <label for="email">Email</label>
          <input type="text" id="email" />
          <label for="password">Password</label>
          <input type="password" id="password"/>
          <a href="#" id="forgot_password">Forgot password?</a>
          <div id="keep-me-logged-in">
            <input type="checkbox" checked="checked">
            Keep me logged in
          </div>
          <div class="login-box-content-loginform-buttons">
            <input type="submit" value="Login" />
            <input type="button" value="Create an account" />
          </div>
        </form>
      </div>

      <div class="login-box-content-registerform">
        register
      </div>
    </div>
  </div>

  

  <script>
    $(document).ready(function() {
      var is_cookie = true; // here will be a feature in nearly future

      $('.login-box-content button').click(function() {
        console.log('clicked');
        $('.login-box-content-buttons').hide();
        if (is_cookie) {
          console.log('login');
          $('.login-box-content-loginform').show();
        } else {
          console.log('register');
          $('.login-box-content-registerform').show();
        }
      });
    });
  </script>
</%def>

<div style="float: left; clear: left;">kazkas<!--<ul class="about-box feature-box">
    <li class="feature icon-subjects-file"><strong>${_('Academic resources')}</strong> &ndash;
    ${_('Add your study material (notes and files).')}</li>
    <li class="feature icon-group"><strong>${_('Student groups')}</strong> &ndash;
      ${_('Create and join private or public groups to communicate and collaborate.')}</li>
    <li class="feature icon-discussions"><strong>${_('Discussions')}</strong> &ndash;
      ${_('Share knowledge and discuss academic subjects with students and teachers.')}</li>
  </ul>--></div>

<div class="clearfix"></div>

%if c.departments:
${university_box(c.departments, _("Departments:"))}
%endif
