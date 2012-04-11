<%inherit file="/prebase.mako" />

<script src="/javascript/slides.min.jquery.js"></script>
<script src="/javascript/jquery.colorbox-min.js"></script>
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
                      <img src="/img/icons/add-icon-big.png" />
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
                <img src="/img/icons/teacher-icon-big.png" />
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

          <div class="login-box-content-registerform" style="width: 250px;">
            <form method="post" id="sign-up-form" action="${url(controller='home', action='register')}">
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
                <option value="${university['url_path']}">${university['title']}</option>
                % endfor
              </select>

              <div id="accept-terms">
                <input type="checkbox" name="accept_terms" id="accept-terms-checkbox" value="1">
                <a href="#">${_('I accept terms and regulations')}</a>
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
                     type="button"
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
                    <input type="checkbox" name="accept_terms" id="pp_accept-terms-checkbox" value="1">
                    <a href="#">${_('I accept terms and regulations')}</a>
                </div>

                <br />
                <input class="black" type="submit" value="${_('Create an account')}" />
            </form>
        </div>
    </div>
</div>

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
        $(".add_university_button").colorbox({inline:true, height: '450px'});
        var errors = 0;

        // POP-UP starts
        // Create user form validation
        $('#create-account-form').submit(function() {
            if ($('#create-account-form input[name="name"]').val().length == 0) {
                $('#create-account-form input[name="name"]').css('border', '1px solid red');
                errors += 1;
            } else {
                $('#create-account-form input[name="name"]').css('border', '1px solid black');
            }

            if ($('#create-account-form input[name="email"]').val().length == 0) {
                $('#create-account-form input[name="email"]').css('border', '1px solid red');
                errors += 1;
            } else {
                $('#create-account-form input[name="email"]').css('border', '1px solid black');
            }

            if ($('#pp_accept-terms-checkbox').is(':checked')) {
                $('#pp_accept-terms span').remove();
            } else {
                errors += 1;
                $('#pp_accept-terms span').remove();
                $('#pp_accept-terms').prepend('<span class="error-message">${_("You must agree to the terms")}<br /></span>');
            }

            if (errors !== 0) {
                return false;
            }

            errors = 0;
        });
        // POP-UP ends

        // if user clicks "I'm student" or "I'm a teacher"
        $('.login-box-content button').click(function() {
            var type = $(this).attr('class');

            $('#person').val(type);

            $('.login-box-content-buttons').hide();
            $('.login-box-content-registerform').show();
        });

        // if user clicks on slide's button "Register as a teacher"
        $('.register-as-a-teacher').click(function() {
            $('.login-box-content-buttons').hide();
            $('.login-box-content-registerform').show();

            $('#person').val('teacher');
        });

        // let's check validation of registration form:
        // if user is clicked on checkbox, enable submitting
        $('#accept-terms-checkbox').click(function() {
            if (this.checked) {
                $('#accept-terms span').remove();
            }
        });

        $('#pp_accept-terms-checkbox').click(function() {
            if (this.checked) {
                $('#pp_accept-terms span').remove();
            }
        });

        $('#sign-up-form').submit(function() {
            if ($('#university-you-belong-to option:selected').val() == -1) {
                $('#university-you-belong-to').css('border', '1px solid red');
                $('#location_id_errors').empty().append('${_("Required")}');

                return false;
            }

            if ($('#accept-terms-checkbox').is(':checked')) {
                // everything is ok, continue
            } else {
                $('#accept-terms span').remove();
                $('#accept-terms').prepend('<span class="error-message">${_("You must agree to the terms")}<br /></span>');
                return false;
            }
        });

        // checks if exists any error
        if ($('#sign-up-form .error-container').length > 0) {
            $('.login-box-content-buttons').hide();
            $('.login-box-content-registerform').show();
        }

        $('#university-you-belong-to').change(function() {
            if ($('#university-you-belong-to option:selected').val() == '') {
                $('#university-you-belong-to').css('border', '1px solid red');
                $('#location_id_errors').empty().append('${_("Required")}');
            } else {
                $('#university-you-belong-to').css('border', 'none');
                $('#location_id_errors').empty();
            }
        });

        $('#new_university_form').submit(function() {
            $.ajax({
                type: 'POST',
                url: '${url(controller='structure', action='create_university')}',
                data: $(this).serialize(),
                success: function(data) {
                    if (data) {
                        var errors = jQuery.parseJSON(data);

                        $('.errors-box').empty();

                        $.each(errors, function(field, value) {
                            $('#' + field + '-errors-box').append('<p class="error-message">' + value + '</p>');
                        });
                    } else {
                        $('#add_university_form').hide();
                        $('#add_university_create_account').show();
                        $('#university_name').text($('#title').val());
                        $('#pp_location_id').val($('#title_short').val());
                        $('#pp_person').val('student');
                    }
                }
            });

            return false;
        });

        $('#create_university_button').click(function() {
            $('#new_university_form').submit();
        });
    });
</script>
