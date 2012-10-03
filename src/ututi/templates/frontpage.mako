<%inherit file="/prebase.mako" />

<%def name="unis_listing(university)">
    <div class="university-entry university-entry-frontpage clearfix ">
      <div class="logo">
        <img src="${url(controller='structure', action='logo', id=university['id'], width=40, height=40)}" alt="logo" title="${university['title']}"/>
      </div>

      <div class="title">
        <a href="${university['url']}" title="${university['title']}">${h.ellipsis(university['title'], 36)}</a>
      </div>
      <ul class="icon-list statistics">
        <li class="icon-subject" title="${_('Subjects')}">${university['n_subjects']}</li>
        <li class="icon-file" title="${_('Files')}">${university['n_files']}</li>
        <li class="icon-group" title="${_('Groups')}">${university['n_groups']}</li>
      </ul>
    </div>
</%def>

<%def name="new_university_popup()">
  ${h.javascript_link('/javascript/jquery.colorbox-min.js')}
  ${h.javascript_link('/javascript/frontpage.js')}

  <div style="display: none;">
      <div id="add_university" class="blue-box">
          <div id="add_university_form">
              <h2>${_('Add your university')}</h2>

              <form method="post"
                    action="${url(controller='structure', action='create_university')}"
                    name="new_university_form"
                    id="new_university_form">

                ${h.input_line('title', _('Title'))}
                <div id="title-errors-box" class="errors-box"></div>

                ${h.input_line('title_short', _('Short title'))}
                <div id="title_short-errors-box" class="errors-box"></div>

                ${h.input_line('site_url', _('WWW address'))}
                <div id="site_url-errors-box" class="errors-box"></div>

                <br /><br />

                <input class="black"
                       type="submit"
                       id="create_university_button"
                       value="${_('Create university')}" />
              </form>
          </div>

          <div id="add_university_create_account" style="display: none;">
              <h2>${_('Create account')}</h2>

              <form method="post" id="create-account-form" action="/register">
                  <input type="hidden" name="location_id" id="pp_location_id" value="" />
                  <input type="hidden" name="person" id="pp_person" value="" />

                  ${h.input_line('name', _('Name'))}
                  ${h.input_line('email', _('Email'))}
                  ${_('University you belong to')}: <strong><div id="university_name"></div></strong><br /><br />

                  <div id="pp_accept-terms">
                      <input type="checkbox" name="accept_terms" id="pp_accept-terms-checkbox" value="1" required="required">
                      <a href="${url(controller='home', action='terms')}">${_('I accept terms and regulations')}</a>
                  </div>

                  <br />
                  <input class="black" type="submit" value="${_('Create an account')}" />
              </form>
          </div>
      </div>
  </div>
</%def>

<script>document.body.style.background="#ffffff";</script>

<div id="layout-wrap" class="clear no-border">
  <div id="main-content">
    <div class="content-inner">
      <div id="slides">
        <div class="slides_container">
          <div id="features-social-network">
            <h1 class="page-title">${_('Private social network for universities')}</h1>

            <ul>
              <li>${_('Groups of students')}</li>
              <li>${_('Teachers')}</li>
              <li>${_('Subjects')}</li>
              <li>${_('University news')}</li>
              <li>${_('Lecture material')}</li>
            </ul>

              <a class="add_university_button" href="#add_university">
                  <button class="black">
                      <img src="${url('/img/icons/add-icon-big.png')}" />
                      <span>${_('Add your university')}</span>
                  </button>
              </a>
          </div>

          <div id="features-teacher">
            <h1 class="page-title">${_("Teachers' academical workspaces")}</h1>

            <div id="features-teacher-1" class="features-teacher-text">${_('Space to place lecture material')}</div>
            <div id="features-teacher-2" class="features-teacher-text">${_('Academic site with biography, publications and contacts')}</div>
            <div id="features-teacher-3" class="features-teacher-text">${_('Easy communicatio with students')}</div>

            <button class="black register-as-a-teacher">
                <img src="${url('/img/icons/teacher-icon-big.png')}" />
                <span>${_('Register as a teacher')}</span>
            </button>
          </div>

          <div id="features-student">
            <h1 class="page-title">${_('Useful tools for students')}</h1>

            <ul>
              <li>${_('Correspondence publicly and inside of group')}</li>
              <li>${_("Up to 500Mb private group's storage")}</li>
              <li>${_('Lecture material')}</li>
              <li>${_('And more...')}</li>
            </ul>

            <form action="${url(controller='search', action='browse')}">
                <button class="black">
                    <img src="${url('/img/icons/finder-icon.png')}" />
                    <span>${_('Find your university')}</span>
                </button>
            </form>
          </div>
        </div><!-- .slides_container -->
      </div><!-- #slides -->

      <div class="login-box" style="width: 330px;">
        <div class="login-box-title">
          <div class="login-box-title-text">
            ${_('Register at the university')}
          </div>

          <hr />
        </div>

        <div class="login-box-content" style="margin-bottom: 20px;">
          <div class="login-box-content-buttons">
            <button style="width: 220px" class="student" type="button">
              <img class="icon" alt="${_('I am a student')}" src="/img/student-icon.png">${_('I am a student')}
            </button>

            <button style="width: 220px" class="teacher" type="button">
              <img class="icon" alt="${_('I am a teacher')}" src="/img/teacher-icon.png">${_('I am a teacher')}
            </button>
          </div>

          <div class="login-box-content-registerform" style="width: 250px;">
            <form method="post" id="sign-up-form" action="${url(controller='home', action='register')}">
              <form:error name="name" format="raw" />
              <label for="name">${_('Name')}</label>
              <input type="text" name="name" id="name" style="width: 230px;" required>
              <form:error name="email" format="raw" />
              <label for="email">${_('Email')}</label>
              <input type="text" name="email" id="email" style="width: 230px;" required>

              <label for="university-you-belong-to">
                  ${_('University you belong to')}
                  <span class="error-message" id="location_id_errors"></span>
              </label>
              <select id="university-you-belong-to" name="location_id" required>
                <option value="" selected>${_('Pick from the list')}:</option>
                <option value="0">--- ${_('Create new university')} ---</option>
                % for university in c.all_universities:
                <option value="${university['url_path']}"
                        id="location_${university['id']}">${university['title']}</option>
                % endfor
              </select>

              <div id="accept-terms">
                <input type="checkbox" name="accept_terms" id="accept-terms-checkbox" value="1" required="required">
                <a href="${url(controller='home', action='terms')}">${_('I accept terms and regulations')}</a>
              </div>
              <input type="hidden" value="" name="person" id="person" />
              <input type="submit" value="${_('Create an account')}" id="create_button">
            </form>
          </div>
        </div><!-- .login-box-content -->
      </div><!-- .login-box -->

      <div class="clear university-box">
        <div class="section-header">
            <h2 class="academy">${_('Universities already are on Ututi')}</h2>
            <div class="section-header-links">
                <a href="${url(controller='search', action='browse')}">${_('More universities')} >></a>
            </div>
        </div>

        <div>
            % for university in c.universities:
                ${unis_listing(university)}
            % endfor
        </div>
      </div><!-- .university-box -->
    </div><!-- .container-inner -->
  </div><!-- #main-content -->
</div><!-- #layout-wrap -->

${new_university_popup()}

<script>
    // Translations for /javascript/frontpage.js
    var required = '${_("Required")}';
    var agreement = '${_("You must agree to the terms")}'; 


  $(function() { 
      $("#slides").slides({
          preload: true,
          preloadImage: '/img/loading.gif',
          play: 5000,
          pause: 2500,
          hoverPause: true
      }); 
  });
</script>

${h.javascript_link('/javascript/slides.min.jquery.js')}
