<%namespace file="/sections/messages.mako" import="*"/>

<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="body_class()"></%def>

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
            <a href="${url(controller='group', action='index', id=mship.group.group_id)}"
               ${h.trackEvent(None, 'group_home', 'top_menu')} title="${mship.group.title}">
              ${h.ellipsis(mship.group.title, 18)}
            </a>
          </div>
        </li>
      %endfor
      <li class="bottom"><div><a href="${url(controller='group', action='add')}" title="${_('Create a new group')}">${_('New group')}</a></div></li>
    </ul>
  </div>
  <div class="item menuitem">
      <a href="${url(controller='community', action='index')}">${_("community")}</a>
  </div>
  <div class="item menuitem">
    <a href="${url(controller='profile', action='browse')}">${_("search")}</a>
  </div>
  <div class="item menuitem">
    <a href="${url(controller='profile', action='home')}" ${h.trackEvent(None, 'user_home', 'menu')}>${_("home")}</a>
  </div>

</div>

<div class="personal-info">
  <div class="personal-logo">
    <a href="${url(controller='profile', action='edit')}" id="user_profile_edit_link" title="${_('Change your personal information')}">
      % if c.user.logo is not None:
        <img src="${url(controller='user', action='logo', id=c.user.id, width=60, height=60)}" alt="logo" />
      % else:
        ${h.image('/images/user_logo_45x60.png', alt='logo')|n}
      % endif
    </a>
  </div>
  <div id="personal-data">
    <div class="fullname">${c.user.fullname}</div>
    <div class="small email">
      ${c.user.emails[0].email}
    </div>
    <div class="medals">
      % for medal in c.user.all_medals():
          ${medal.img_tag()}
      % endfor
    </div>
  </div>
  <br class="clear-right" />
</div>
<div id="profile-edit-link">
  <a href="${url(controller='profile', action='edit')}" class="forward-link">
    ${_('Change profile')}
  </a>
</div>

%else:
${h.javascript_link('/javascript/forms.js')|n}
<form method="post" id="login_form" action="${url('/login')}">
  <input type="hidden" name="came_from" value="${request.params.get('came_from', request.url)}" />
  % if request.params.get('login'):
    <div class="error">${_('Wrong password or username!')}</div>
  % endif
  <div class="form-field overlay" style="clear: none;">
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
    <a rel="nofollow" class="small-link small" href="${url(controller='home', action='pswrecovery')}">${_('forgotten password?')}</a>
  </div>
</form>
<script type="text/javascript">
  $(window).load(function() {
    $(".overlay label").labelOver('over');
  });
</script>
%endif
</%def>

<%def name="portlets()">
<div id="sidebar">
%if c.user:
  ${user_sidebar()}
%endif
</div>
</%def>

<%def name="flash_messages()">
<div id="flash-messages">
  % if c.serve_file:
  <iframe style="display: none;" src="${c.serve_file.url()}"> </iframe>
  % endif

  <% messages = h.flash.pop_messages() %>
  % for message in messages:
  <div class="flash-message"><span class="close-link hide-parent">${_('Close')}</span><span>${h.literal(unicode(message))}</span></div>
  % endfor
  ${invitation_messages(c.user)}
  ${request_messages(c.user)}
  ${confirmation_messages(c.user)}
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
          <a ${tab.get('event', '')} class="subbreadcrumb" title="${tab.get('title')}" href="${tab.get('link')}">${tab.get('title')}</a>
        </div>
      </div>
    %endfor
  </div>
  %endif
</%def>

<%def name="breadcrumbs(breadcrumbs)">
<div id="breadcrumb-container">
  <%
     if c.user:
         u_url = url(controller='profile', action='browse')
         track_event = h.trackEvent(None, 'user_search', 'logo')
     else:
         track_event = ''
         u_url = url('/')
  %>
  %if breadcrumbs:
  <a rel="nofollow" ${track_event} href="${u_url}" title="Ututi" id="ulogo">
    ${h.image('/images/logo_small.gif', alt='logo')|n}
  </a>
  %else:
  <a rel="nofollow" href="${u_url}" title="Ututi" id="ulogo">
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
      ## XXX a nasty hack to record the type of the object we are showing breadcrumbs for
      <div class="title"><a href="${tag.url()}" ${h.trackEvent(None, '%s_breadcrumbs' % c.security_context.__class__.__name__, 'level%s' % index)} title="${tag.title}">${tag.title_short}</a></div>
    </div>
    %endfor
  </div>
  %endif

  %if breadcrumbs:
  <ul id="breadcrumbs">
    <%
       if isinstance(breadcrumbs[-1], list):
         breadcrumbs = breadcrumbs[:-1]

       if len(breadcrumbs) > 1:
         ellipsis = [20, 40]
       else:
         ellipsis = [50]
       %>
    %for ind, breadcrumb in enumerate(breadcrumbs):
      %if ind > 0:
        <li class="breadcrumb">
      %else:
        <li class="no-bullet">
      %endif

      <div>
        %if breadcrumb.get('logo', None) is not None:
          <img src="${breadcrumb['logo']}" alt="${_('logo')}"/>
        %endif

        <a class="breadcrumb" title="${breadcrumb.get('title')}" href="${breadcrumb.get('link')}">
          ${h.ellipsis(breadcrumb.get('title'),ellipsis[ind])}
        </a>
      </div>
    </li>
    %endfor
    </ul>
    %endif
  </div>
</%def>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <script type="text/javascript">
      var lang = '${c.lang}';
    </script>
    ${h.javascript_link('/javascript/jquery-1.3.2.min.js')}
    ${h.javascript_link('/javascript/ajaxupload.3.5.js')}
    ${h.javascript_link('/javascript/jquery.qtip.min.js')}
    ${h.javascript_link('/javascript/tooltips.js')}
    ${h.stylesheet_link('/style.css')}
    ${h.javascript_link('/javascript/expand.js')}
    ${h.javascript_link('/javascript/hide_parent.js')}
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="verify-v1" content="TSVWuU2veWvlR1F0wRgzprUz3gMtHFWbGKmOLQ3cmWQ=" />
    ${self.head_tags()}
    <title>
      ${self.title()} - ${_('UTUTI')}
    </title>
    <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '${c.google_tracker}']);
      _gaq.push(['_trackPageview']);

      (function() {
      var ga = document.createElement('script');
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      ga.setAttribute('async', 'true');
      document.documentElement.firstChild.appendChild(ga);
      })();

    </script>
  </head>

  <body class="${self.body_class()}">
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
          ${self.flash_messages()}
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
        <%
           nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '')
        %>
        Copyright <em>UAB „Ututi“</em>
        <div id="footer-links">
          <a ${nofollow} href="${url(controller='home', action='about')}">${_('About Ututi')}</a> |
          <a ${nofollow} href="${_('ututi_blog_url')}">${_('U-blog')}</a> |
	  %if c.tpl_lang in ['lt']:
             <a ${nofollow} href="${url(controller='home', action='advertising')}">${_('Advertising')}</a> |
	  %endif
          <a href="${url(controller='home', action='statistics')}">${_('Statistics')}</a> |
          <a ${nofollow} href="${url(controller='home', action='terms')}">${_('Terms of use')}</a>
        </div>

      </div>
    </div>

    %if c.lang in ['lt', 'en']:
    ${h.javascript_link('/javascript/uservoice.js')|n}
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
    %else:
      ${h.javascript_link('/javascript/sugester.js')|n}
    %endif
  </body>
</html>
