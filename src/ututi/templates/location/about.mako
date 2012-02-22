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
    height: 80px;

    background-image: linear-gradient(bottom, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -o-linear-gradient(bottom, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -moz-linear-gradient(bottom, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -webkit-linear-gradient(bottom, #FFFFFF 0%, #E3EAF4 100%);
    background-image: -ms-linear-gradient(bottom, #FFFFFF 0%, #E3EAF4 100%);

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
    text-shadow: 0px 0px 1px #999999;

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
    margin: 20px 0 30px 0;
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
      <div class="login-box-title-text">REGISTRUOTIS</div>
      <hr />
    </div>

    <div class="login-box-content">
      <button type="button"><img src="/img/student-icon.png" alt="I am a student" class="icon" />I am a student</button>
      <button type="button"><img src="/img/teacher-icon.png" alt="I am a teacher" class="icon" />I am a teacher</button>
    </div>
  </div>
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
