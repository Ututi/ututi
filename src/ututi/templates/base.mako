<%namespace file="/sections/messages.mako" import="*"/>

<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/search.mako" import="*"/>


<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="personal_block()">
%if c.user:
<div id="personal-menu">
  <div class="item">
    ${h.link_to(_("log out"), url('/logout'))}
  </div>
  <div class="click2show item">
    <span class="click title">${_('groups')}</span>
    <ul class="expanding-menu show">
      <li class="top"><div>&nbsp;</div></li>
      %for mship in c.user.memberships:
        <li>
          <div>
            <a href="${url(controller='group', action='home', id=mship.group.group_id)}" title="${mship.group.title}">
              ${h.ellipsis(mship.group.title, 18)}
            </a>
          </div>
        </li>
      %endfor
      <li class="bottom"><div><a href="${url(controller='group', action='add')}" title="${_('Create a new group')}">${_('New group')}</a></div></li>
    </ul>
  </div>
  <div class="item">
    <a href="${url(controller='forum', forum_id='community')}">${_("community")}</a>
  </div>
  <div class="item">
    <a href="${url(controller='profile', action='search')}">${_("search")}</a>
  </div>
  <div class="item">
    <a href="${url(controller='profile', action='home')}">${_("home")}</a>
  </div>

</div>

<div class="personal-info">
  <div class="personal-logo">
    <a href="${url(controller='profile', action='edit')}" title="${_('Upload your personal logo')}">
      % if c.user.logo is not None:
        <img src="${url(controller='user', action='logo', id=c.user.id, width=60, height=60)}" alt="logo" />
      % else:
        ${h.image('/images/user_logo_45x60.png', alt='logo')|n}
      % endif
    </a>
  </div>
  <div id="personal-data">
    <div class="fullname">${c.user.fullname}</div>
    <div class="small email">${c.user.emails[0].email}</div>
  </div>
  <br style="clear: right; height: 1px;"/>
</div>
%else:
${h.javascript_link('/javascripts/forms.js')|n}
<form method="post" id="login_form" action="${url('/login')}">
  <input type="hidden" name="came_from" value="${request.params.get('came_from', request.url)}" />
  % if request.params.get('login'):
    <div class="error">${_('Wrong password or username!')}</div>
  % endif
  <div class="form-field overlay">
    <label for="login" class="small">${_('Email')}</label>
    <div class="input-line"><div>
        <input type="text" size="20" id="login" name="login" class="small line" value="${request.params.get('login')}" />
    </div></div>
  </div>
  <br style="clear: right; height: 0; margin: 0; padding: 0;"/>
  <div class="form-field overlay">
    <label for="password" class="small">${_('Password')}</label>
    <div class="input-line"><div>
        <input type="password" size="20" name="password" id="password" class="small line"/>
    </div></div>
  </div>
  <br style="clear: right; height: 0; margin: 0; padding: 0;"/>
  <div class="form-field">
    <span class="btn"><input class="submit small" type="submit" name="join" value="Login" /></span>
  </div>
  <br style="clear: right; height: 0; margin: 0; padding: 0;"/>
  <div class="form-field">
    <a class="small-link small" href="${url(controller='home', action='pswrecovery')}">${_('forgotten password?')}</a>
  </div>
</form>
<script type="text/javascript">
  $(".overlay label").labelOver('over');
</script>
%endif
</%def>

<%def name="portlets()">
<div id="sidebar">
%if c.user:
  ${search_portlet(parts=['text'], target=url(controller='profile', action='search'))}

  ${user_subjects_portlet()}
  ${user_groups_portlet()}
%endif
</div>
</%def>


<%def name="tabs(tabs)">
  %if isinstance(tabs, list):
  <div id="tabs">
    %for tab in tabs:
      <%
         cls = tab.get('selected', False) and 'active' or ''
      %>
      <div class="tab ${cls}">
        <div>
          <a ${tab.get('event', '')|n} class="subbreadcrumb" title="${tab.get('title')}" href="${tab.get('link')}">${tab.get('title')}</a>
        </div>
      </div>
    %endfor
  </div>
  %endif
</%def>

<%def name="breadcrumbs(breadcrumbs)">
<div id="breadcrumb-container">
  %if breadcrumbs:
  <a href="${url('/')}" title="home" id="ulogo">
    ${h.image('/images/logo_small.gif', alt='logo')|n}
  </a>
  %else:
  <a href="${url('/')}" title="home" id="ulogo">
    ${h.image('/images/logo.gif', alt='logo')|n}
  </a>
  %endif
  %if c.object_location:
  <div id="location">
    %for (index, tag) in enumerate(c.object_location.hierarchy(True)):
    <%
       if index > 0:
           cls = 'bullet-small'
       else:
           cls = ''
    %>

    <div class="location-tag ${cls}">
      %if tag.logo:
      <img src="${url(controller='structure', action='logo', id=tag.id, height=20, width=40)}" alt="location tag logo"/>
      %endif
      <div class="title"><a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a></div>
    </div>
    %endfor
  </div>
  %endif

  %if breadcrumbs:
  <ul id="breadcrumbs">
    <%
       first_bc = True
       %>
    %for breadcrumb in breadcrumbs:
    %if not first_bc:
    <li class="breadcrumb">
      %else:
    <li class="no-bullet">
      <%
         first_bc = False
         %>
      %endif
      %if isinstance(breadcrumb, dict):
      <div>
        %if breadcrumb.get('logo', None) is not None:
          <img src="${breadcrumb['logo']}" alt="${_('logo')}"/>
        %endif

        <a class="breadcrumb" title="${breadcrumb.get('title')}" href="${breadcrumb.get('link')}">
          ${breadcrumb.get('title') | h.ellipsis}
        </a>
      </div>
      %endif
    </li>
    %endfor
    </ul>
    %endif
  </div>
</%def>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    ${h.javascript_link('/javascripts/jquery-1.3.2.min.js')|n}
    ${h.javascript_link('/javascripts/ajaxupload.3.5.js')|n}
    ${h.javascript_link('/javascripts/jquery.qtip.min.js')|n}
    ${h.javascript_link('/javascripts/tooltips.js')|n}
    ${h.stylesheet_link('/stylesheets/style.css')|n}
    ${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
    ${h.javascript_link('/javascripts/expand.js')|n}
    ${h.javascript_link('/javascripts/hide_parent.js')|n}
    ${h.javascript_link('/javascripts/ckeditor/ckeditor.js')|n}
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="verify-v1" content="TSVWuU2veWvlR1F0wRgzprUz3gMtHFWbGKmOLQ3cmWQ=" />
    ${self.head_tags()}
    <title>
      ${_('UTUTI')} - ${self.title()}
    </title>
  </head>

  <body>
    <div id="container">
      %if c.testing:
      <div style="background: #F7FF00">${_('This is a testing version - this is just a copy of the information! Changes you make will not be persisted!')}</div>
      %endif
      <div id="header">
        <div id="personal-box" class="rounded-block">
          ${self.personal_block()}
        </div>

        ${breadcrumbs(c.breadcrumbs)}
      </div>

      <div id="content">
        ${self.portlets()}

        <div class="inside" id="page-content">
          <div id="flash-messages">
            % if c.serve_file:
            <iframe style="display: none;" src="${c.serve_file.url()}"> </iframe>
            % endif
            <% messages = h.flash.pop_messages() %>
            % for message in messages:
            <div class="flash-message"><span class="close-link hide-parent">${_('Close')}</span><span>${message}</span></div>
            % endfor
            ${invitation_messages(c.user)}
            ${request_messages(c.user)}
          </div>

          %if c.breadcrumbs:
            ${tabs(c.breadcrumbs.pop())}
          %endif
          <div id="body-container">
            ${self.body()}
          </div>
          <br style="clear: both;"/>
        </div>

      </div>

      <div id="footer" class="small">
        Copyright <a href="http://www.nous.lt">UAB „Nous“</a>
        <div id="footer-links">
          <a href="${url(controller='home', action='about')}">${_('Apie Ututi')}</a> |
          <a href="${_('ututi_blog_url')}">${_('U-blog')}</a> |
          <a href="${url(controller='home', action='terms')}">${_('Terms of use')}</a>
        </div>

      </div>
    </div>

    <script type="text/javascript">
      var uservoiceJsHost = ("https:" == document.location.protocol) ? "https://uservoice.com" : "http://cdn.uservoice.com";
      document.write(unescape("%3Cscript src='" + uservoiceJsHost + "/javascripts/widgets/tab.js' type='text/javascript'%3E%3C/script%3E"))
    </script>
    <script type="text/javascript">
    UserVoice.Tab.show({
      /* required */
      key: 'ututi',
      host: 'ututi.uservoice.com',
      forum: '26068',
      /* optional */
      alignment: 'left',
      background_color:'#ff7800',
      text_color: 'white',
      hover_color: '#9d9d9d',
      lang: 'en'
    })
    </script>
    <script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <script type="text/javascript">
      try {
      var pageTracker = _gat._getTracker("${c.google_tracker}");
      pageTracker._trackPageview();
      } catch(err) {}
    </script>
  </body>
</html>
