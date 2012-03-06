<%inherit file="/location/base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
</%def>

<%def name="css()">
  ${parent.css()}

  .teacher-entry {
    width: 50%;
    float: left;
    margin-bottom: 30px;
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
    padding-left: 20px;
    padding-bottom: 10px;
    width: 350px;
    float: right;
    font-family: Arial,Verdana,sans-serif;
  }

  .about-box .feature {
    width: 380px;
    margin-top: 4px;
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

  .features {
    float: left;
    clear: left;
  }

  .features p {
    font-weight: bold;
    text-transform: uppercase;
    font-family: Arial,Verdana,sans-serif;
    font-size: 14px;
  }

  /* Overwrites a design from fixed.css .*/
  .feature-box {
    background: none;
    border: none;
  }

  .no-faculties-box {
    background-color: #eff2f5;
    -webkit-border-radius: 10px;
    -moz-border-radius: 10px;
    border-radius: 10px;
    border: 10px solid #eceff3;
    font-family: Arial,Verdana,sans-serif;
    margin-top: 5px;
  }

  .no-faculties-box-title {
    padding: 25px;
    color: #3d617a;
    font-family: Arial,Verdana,sans-serif;
    font-size: 18px;
  }

  .no-faculties-box-features {
    margin-left: 50px;
    font-weight: bold;
    font-size: 13px;
  }

  .no-faculties-box-features ul {
    background: url('/img/icons.com/about/academics.png') center left no-repeat;
  }

  .no-faculties-box-features li {
    margin-bottom: 16px;
    list-style-type: none;
    background: url('/img/icons.com/about/bullet.png') no-repeat;
    padding-left: 20px;
  }

  .no-faculties-box-button {
    border-top: 1px solid #dbe1e9;
    margin: 25px 0 5px 0;
    font-weight: bold;
    font-size: 18px;
    font-family: Arial,Verdana,sans-serif;
    padding: 10px 0 5px 15px;
  }

  .no-faculties-box-button a {
    background: transparent url('/img/icons.com/about/add-faculty.png') center left no-repeat;
    display: inline-block;
    padding-left: 40px;
    line-height: 35px;
  }


  .icon-academy a {
    margin-right: 100px;
    padding-right: 50px;
  }

</%def>

<%def name="university_entry(uni)">
<div class="university-entry clearfix">
  <div class="logo">
    <img src="${url(controller='structure', action='logo', id=uni['id'], width=40, height=40)}"
         alt="logo" />
  </div>
  <div class="title">
    <a href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 36)}</a>
  </div>
  <ul class="icon-list statistics">
    <li class="icon-subject"> ${uni['n_subjects']} </li>
    <li class="icon-file"> ${uni['n_files']} </li>
    <li class="icon-group"> ${uni['n_groups']} </li>
  </ul>
</div>
</%def>

<%def name="university_box(unis, title)">
%if unis:
<div class="university-box">
  <div class="section-header">
    <h2 class="academy">Faculties of ${c.location.title}</h2>

    <div class="section-header-links">
      %if h.check_crowds(['moderator']):
        <a class="create-link" href="">${_("+ Add department")}</a>
      %endif
      <a href="#">${_('All faculties')} >></a>
  </div>
  </div>

  <div class="clearfix"></div>

  %for uni in unis:
    ${university_entry(uni)}
  %endfor
</div>
%endif
</%def>

<%def name="teachers_box()">
<div class="teachers-box clear">
  <div class="section-header">
    <h2 class="teacher">Teachers of ${c.location.title}</h2>

    <div class="section-header-links">
      % if h.check_crowds(['moderator']):
        <a class="create-link" href="#">${_("+ Add teacher")}</a>
      % endif
      <a href="#">${_('All teachers')} >></a>
    </div>
  </div>

  <div class="clearfix"></div>

  ${teacher_entry()}
</div>
</%def>

<%def name="teacher_entry()">
% for i in range(10):
<div class="teacher-entry clearfix">
  <div class="logo">
    <img src="/structure/180/logo/40/40" alt="logo" />
  </div>

  <div class="title">
    <a href="#" title="title">Jonas Ponas</a>
  </div>
  <ul class="icon-list statistics">
    <li class="icon-file"><a href="#">dalykas</a></li>
    <li class="icon-academy"><a href="#">fakultetas</a></li>
  </ul>
</div>
% endfor
</%def>

<%def name="no_faculties_box()">
<div class="no-faculties-box">
  <div class="no-faculties-box-title">
    ${h.literal(_("Add faculties to %s's social network") % ('<strong>%s</strong>' % h.simple_declension(c.location.title, lang=c.lang)))}
  </div>

  <div class="no-faculties-box-features">
    <ul>
      <li>${_('Add a facultie you belong to')}</li>
      <li>${_('Create your academic group')}</li>
      <li>${_('Invite your coleagues and professors to join')}</li>
    </ul>
  </div>

  <div class="no-faculties-box-button">
    <a href="${url(controller='structure', action='index')}" title="${_('Add a facultie now')}">${_('Add a facultie now')}</a>
  </div>
</div>
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
      <div class="login-box-title-text">${_('Register or login')}</div>
      <div class="login-box-title-login-as-student" style="display: none;">${_('Login as a student')}</div>
      <div class="login-box-title-login-as-teacher" style="display: none;">${_('Login as a teacher')}</div>
      <div class="login-box-title-register-as-student" style="display: none;">${_('Register as a student')}</div>
      <div class="login-box-title-register-as-teacher" style="display: none;">${_('Register as a teacher')}</div>
      <hr />
    </div>

    <div class="login-box-content">
      <div class="login-box-content-buttons">
        <button type="button" class="student"><img src="/img/student-icon.png" alt="${_('I am a student')}" class="icon" />${_('I am a student')}</button>
        <button type="button" class="teacher"><img src="/img/teacher-icon.png" alt="${_('I am a teacher')}" class="icon" />${_('I am a teacher')}</button>
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
          <input type="submit" value="${_('Login')}" />
          <input type="button" id="create_account" value="${_('Create an account')}" />
        </form>
      </div>

      <div class="login-box-content-registerform">
        <form action="/register" method="POST">
          <label for="email">${_('Email')}</label>
          <input class="university-email" type="text" id="email" name="username" />
          <label for="password">${_('Password')}</label>
          <input class="university-password" type="password" id="password" name="password" />
          <a href="/password" id="forgot_password">${_('Forgot password?')}</a>
          <div id="keep-me-logged-in">
            <input type="checkbox" checked="checked" name="remember">
            ${_('Keep me logged in')}
          </div>
          <input type="button" value="${_('Create an account')}" />
        </form>
      </div>
    </div>
  </div>

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
                });
            });
        });
    </script>
</%def>

<div class="features">
  <p>Here you can find:</p>
  <ul class="about-box feature-box">
    <li class="feature icon-subjects-file">
      <strong>${_('Academic resources')}:</strong> 
      ${_('teaching subjects with study materials (notes, files, presentations, audio&amp;video)')}.
    </li>

    <li class="feature icon-group">
      <strong>${_('Students groups')}:</strong> 
      ${_('private and public groups with files area, forum and email for communication and collaboration')}.
    </li>

    <li class="feature icon-discussions">
      <strong>${_('Discussions')}:</strong> 
      ${_('knowlenge sharing and discussions on academic subjects with students and teachers')}.
    </li>

    <li class="feature icon-teachers-profiles">
      <strong>${_('Teachers profiles')}:</strong>
      ${_('academic webpage  with teachers biography, publications, touch cources and contact information')}.
    </li>
  </ul>
</div>

<div class="clearfix"></div>

%if c.departments:
${university_box(c.departments, _("Departments:"))}
## ${teachers_box()}
%else:
${no_faculties_box()}
%endif
