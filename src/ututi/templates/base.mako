<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="personal_block()">
%if c.user:
  <div class="personal-logo">
    % if c.user.logo is not None:
       <img src="${h.url_for(controller='profile', action='logo', id=c.user.id, width=45, height=60)}" />
    % else:
       <div class="XXX" style="height: 60px; width: 45px;"> </div>
    % endif
  </div>
  <div class="personal-info">
    <a class="logout" href="/logout" title="Logout">
      ${h.image('/images/icon_logout.png', alt='logout')|n}
    </a>
    <div>
      <span class="fullname">${c.user.fullname}</span>
      <span class="small">${c.user.emails[0].email}</span>
    </div>
    <div id="user-ratings">
      <span id="user-rating-good" class="user-rating XXX">+178</span>
      <span id="user-rating-evil" class="user-rating XXX">+178</span>
    </div>
  </div>
  <div id="personal-menu" class="XXX">
    <span class="expanding-menu">
      <a href="#" class="title">Home</a>
    </span>
    <span class="expanding-menu">
      <a href="#" class="title">Groups</a>
    </span>
    <span class="expanding-menu">
      <a href="#" class="title">Subjects</a>
    </span>
  </div>
%else:
<form method="post" id="login_form" action="/dologin">
  %if request.GET.get('came_from'):
  <input type="hidden" name="came_from" value="${request.GET.get('came_from')}" />
  %endif

  <div class="form-field overlay">
    <label for="login" class="small">${_('Email')}</label>
    <input class="line" type="text" size="20" id="login" name="login" />
  </div>
  <div class="form-field overlay">
    <label for="password" class="small">${_('Password')}</label>
    <input class="line" type="password" size="20" name="password" id="password" />
  </div>
  <div class="form-field overlay">
    <input class="submit small" type="submit" name="join" value="Login" />
    <a class="small-link small" href="#">Forgotten password?</a>
  </div>
</form>
<script lang="javascript">
  $(".overlay label").labelOver('over');
</script>
%endif
</%def>

<%def name="portlets()">
</%def>

<%def name="portlet(id)">
<div class="sidebar-block" id="${id}">
  <div class="rounded-header">
    <div class="rounded-right">
      <h3 id="${id + '_header'}">${caller.header()}</h3>
    </div>
  </div>
  <div class="content" id="${id + '_content'}">
    ${caller.body()}
  </div>
</div>
</%def>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
    ${h.stylesheet_link('/stylesheets/style.css')|n}
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    ${self.head_tags()}
    <title>
      ${_('UTUTI')} - ${self.title()}
    </title>
  </head>

  <body>
    <div id="container">
      <div id="header">
        <div id="personal-box" class="rounded-block">
          <div class="rounding rounded-header">
            <div class="rounded-right"></div>
          </div>
          <div class="content">
            ${self.personal_block()}
          </div>
          <div class="rounding rounded-footer">
            <div class="rounded-right"></div>
          </div>
        </div>

        %if c.breadcrumbs:
        <a href="/" title="home" id="ulogo">
          ${h.image('/images/logo_small.png', alt='logo')|n}
        </a>
        <div id="breadcrumbs">
          <%
             first_bc = True
          %>
          %for breadcrumb in c.breadcrumbs:
          %if not first_bc:
            ${h.image('/images/bullet_orange.png', alt='bullet')|n}
          %else:
            <%
               first_bc = False
            %>
          %endif
          <a class="breadcrumb" title="${breadcrumb.get('title')}" href="${breadcrumb.get('link')}">
             ${breadcrumb.get('title') | h.ellipsis}
          </a>

          %endfor
        </div>
        %else:
        <a href="/" title="home" id="ulogo">
          ${h.image('/images/logo.png', alt='logo')|n}
        </a>
        %endif

        <div id="content-top">
          <div></div>
        </div>
      </div>

      <div id="content">
        ${self.portlets()}

        <div class="inside" id="page-content">
          ${self.body()}
        </div>

      </div>

      <div id="footer">
        <div id="content-bottom">
          <div></div>
        </div>

        Copyright <a href="#">UAB „Nous“</a>
        <div id="footer-links">
          <a href="#">aaaaa</a> |
          <a href="#">aaasdfasdaa</a> |
          <a href="#">aaa dasfaa</a>
        </div>

      </div>
    </div>

  </body>
</html>
