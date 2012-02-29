<%inherit file="/prebase.mako" />

<script src="/javascript/slides.min.jquery.js"></script>

<div id="layout-wrap" class="clearfix">
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

            <button class="black-button">
                <img src="/img/icons/add-icon-big.png" />
                <span>Pridek savo universiteta</span>
            </button>
          </div>

          <div id="features-teacher">
            <h1 class="page-title">Teachers' academical workspaces</h1>

            <div id="features-teacher-1" class="features-teacher-text">Erdvė destomu dalyku medziagai talpinti</div>
            <div id="features-teacher-2" class="features-teacher-text">Akademinė svetainė su biografija, publikacijomis ir kontaktais</div>
            <div id="features-teacher-3" class="features-teacher-text">Patogus bendravimas su studentais</div>

            <button class="black-button">
                <img src="/img/icons/teacher-icon-big.png" />
                <span>Registruotis kaip destytojas</span>
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

            <button class="black-button">
                <img src="/img/icons/finder-icon.png" />
                <span>Ieskoti savo universiteto</span>
            </button>
          </div>
        </div><!-- .slides_container -->
      </div><!-- #slides -->

      <div class="login-box" style="width: 330px;">
        <div class="login-box-title">
          <div class="login-box-title-text">
            Registruotis i universiteta
          </div>

          <hr />
        </div>

        <div class="login-box-content" style="margin-bottom: 20px;">
          <div class="login-box-content-buttons">
            <button style="width: 220px" class="student" type="button">
              <img class="icon" alt="I am a student" src="/img/student-icon.png">I am a student
            </button>

            <button style="width: 220px" class="teacher" type="button">
              <img class="icon" alt="I am a teacher" src="/img/teacher-icon.png">I am a teacher
            </button>
          </div>

          <div class="login-box-content-loginform" style="width: 250px;">
            <form method="post" action="/login">
              <label for="name">Name</label>
              <input type="text" name="name" id="name" style="width: 230px;">
              <label for="email">Email</label>
              <input type="text" name="email" id="email" style="width: 230px;">
              <label for="university">University you belong to</label>
              <select id="university-you-belong-to">
                <option>Pick from the list</option>
                <option>test2</option>
              </select>
              <div id="accept-terms">
                <input type="checkbox" checked="checked" name="accept-terms">
                <a href="#">${_('I accept terms and regulations')}</a>
              </div>
              <input type="submit" value="Create an account">
            </form>
          </div>

          <div class="login-box-content-registerform" style="width: 250px;">
            <form method="POST" action="/register">
              <label for="name">Name</label>
              <input type="text" name="name" id="name" style="width: 230px;">
              <label for="password">Email</label>
              <input type="text" name="email" id="email" style="width: 230px;">
              <input type="submit" value="Create an account">
            </form>
          </div>
        </div><!-- .login-box-content -->
      </div><!-- .login-box -->

      <div class="clear">
        universities
      </div>
    </div><!-- .container-inner -->
  </div><!-- #main-content -->
</div><!-- #layout-wrap -->

<script>
  $(function() { 
    $("#slides").slides({
      preload: true,
      play: 5000,
      pause: 2500,
      hoverPause: true
    }); 
  });
</script>


<script>
    $(document).ready(function() {
      var is_cookie = true; // here will be a feature in nearly future

      $('.login-box-content button').click(function() {
        $('.login-box-content-buttons').hide();
        if (is_cookie) {
          $('.login-box-content-loginform').show();
        } else {
          $('.login-box-content-registerform').show();
        }
      });

      $('#create_account').click(function() {
        $('.login-box-content-loginform').hide();
        $('.login-box-content-registerform').show();
      });
    });
</script>
