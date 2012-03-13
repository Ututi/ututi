<%inherit file="/prebase.mako" />

<script src="/javascript/slides.min.jquery.js"></script>
<script>document.body.style.background="#ffffff";</script>


<div id="layout-wrap" class="clear no-border">
  <div id="main-content">
    <div class="content-inner">
      <div id="slides">
        <div class="slides_container">
          <div id="features-social-network">
            <h1 class="page-title">Private social network for universities</h1>

            <ul>
              <li>Studentų grupės</li>
              <li>Dėstytojai</li>
              <li>Dėstomi dalykai</li>
              <li>Universiteto naujienos</li>
              <li>Paskaitų medžiagos</li>
            </ul>

            <button class="black">
                <img src="/img/icons/add-icon-big.png" />
                <span>${_('Add your university')}</span>
            </button>
          </div>

          <div id="features-teacher">
            <h1 class="page-title">${_("Teachers' academical workspaces")}</h1>

            <div id="features-teacher-1" class="features-teacher-text">Erdvė destomu dalyku medziagai talpinti</div>
            <div id="features-teacher-2" class="features-teacher-text">Akademinė svetainė su biografija, publikacijomis ir kontaktais</div>
            <div id="features-teacher-3" class="features-teacher-text">Patogus bendravimas su studentais</div>

            <button class="black register-as-a-teacher">
                <img src="/img/icons/teacher-icon-big.png" />
                <span>${_('Register as a teacher')}</span>
            </button>
          </div>

          <div id="features-student">
            <h1 class="page-title">Useful tools for students</h1>

            <ul>
              <li>Susirašinėjimas viešai ir grupės viduje</li>
              <li>Iki 500Mb privati grupės failų talpykla</li>
              <li>Dėstomų dalykų medžiaga</li>
              <li>Ir dar daugiau...</li>
            </ul>

            <form action="${url(controller='search', action='browse')}">
                <button class="black">
                    <img src="/img/icons/finder-icon.png" />
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

          <div class="login-box-content-loginform" style="width: 250px;">
            <form method="post" id="sign-up-form2" action="/register">
              <label for="name">Name</label>
              <input type="text" name="name" id="name" style="width: 230px;">
              <label for="email">Email</label>
              <input type="text" name="email" id="email" style="width: 230px;">
              <label for="university">University you belong to</label>
              <select id="university-you-belong-to">
                <option>${_('Pick from the list')}</option>
                % for university in c.all_universities:
                <option value="${university['id']}">${university['title']}</option>
                % endfor
              </select>
              <div id="accept-terms">
                <input type="checkbox" name="accept-terms" id="accept-terms-checkbox">
                <a href="#">${_('I accept terms and regulations')}</a>
              </div>
              <input type="submit" value="Create an account" name="" id="create_button">
            </form>
          </div>
        </div><!-- .login-box-content -->
      </div><!-- .login-box -->

      <div class="clear university-box">
        <div class="section-header">
            <h2 class="academy">Universities already are on Ututi</h2>
            <div class="section-header-links">
                <a href="${url(controller='search', action='browse')}">${_('More universities')} >></a>
            </div>
        </div>

        <div>
            % for university in c.universities:
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
            % endfor
        </div>
      </div>
    </div><!-- .container-inner -->
  </div><!-- #main-content -->
</div><!-- #layout-wrap -->

<script>
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


<script>
    $(document).ready(function() {
        var is_cookie = true; // here will be a feature in nearly future

        // if user clicks "I'm student" or "I'm a teacher"
        $('.login-box-content button').click(function() {
            var type = $(this).attr('class');

            if (type == 'student') {
                $('#create_button').attr('name', 'REGISTER_STUDENT');
            } else {
                $('#create_button').attr('name', 'REGISTER_TEACHER');
            }

            $('.login-box-content-buttons').hide();
            if (is_cookie) {
              $('.login-box-content-loginform').show();
            } else {
              $('.login-box-content-registerform').show();
            }
        });

        // if user clicks on slide's button "Register as a teacher"
        $('.register-as-a-teacher').click(function() {
            $('.login-box-content-buttons').hide();
            $('.login-box-content-loginform').show();

            $('#create_button').attr('name', 'REGISTER_TEACHER');
        });

        // let's check validation of registration form:
        // if user is clicked on checkbox, enable submiting
        $('#accept-terms-checkbox').click(function() {
            if (this.checked) {
                $('#create_button').removeAttr('disabled');
            } else {
                $('#create_button').attr('disabled', 'disabled');
            }
        });

        // let's check validation of ragistration form:
        // login button's behaviour
        $('#create_button').click(function() {
            if ($('#accept-terms-checkbox').is(':checked')) {
                // everything is ok, continue
            } else {
                $('#accept-terms span').remove();
                $('#accept-terms').prepend('<span class="error-message">${_("You must agree to the terms")}<br /></span>');
                return false;
            }
        });
    });
</script>
