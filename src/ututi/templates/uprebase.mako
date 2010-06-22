<%namespace file="/sections/messages.mako" import="*"/>

<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="body_class()">
</%def>

<%def name="anonymous_menu()">
<p class="a11y">${_('Main menu')}</p>
<div class="head-nav">
  <ul>
    <li><a href="${url(controller='home', action='index', qualified=True)}">${_('Home')}</a></li>
    <li><a href="${url(controller='search', action='browse', qualified=True)}">${_('Browse')}</a></li>
    <li><a href="${url(controller='home', action='about', qualified=True)}">${_('About')}</a></li>
    <li><a class="orange" href="${url(controller='home', action='join', qualified=True, came_from=url.current())}">${_('Join')}</a></li>
  </ul>
</div>
<p class="a11y">${_('User menu')}</p>
<div class="loggedin-nav" id="personal-data">
    <ul>
        <li><a href="#" id="feedback-link">${_('feedback')}</a></li>
    </ul>
</div>
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
  %if not breadcrumbs:
  <h1 id="siteName"><a rel="nofollow" ${track_event} href="${u_url}" title="Ututi" id="ulogo">Ututi</a></h1>
  %else:
  <h1 id="siteName2"><a rel="nofollow" ${track_event} href="${u_url}" title="Ututi" id="ulogo">Ututi</a></h1>
  %endif

  %if c.object_location or breadcrumbs:
  <ul id="BreadLinks">

  %if c.object_location:
    %for (index, tag) in enumerate(c.object_location.hierarchy(True)):
    <%
       cls = 'first' if index == 0 else 'second'
    %>
    <li class="${cls}">
      <a href="${tag.url()}" ${h.trackEvent(None, '%s_breadcrumbs' % c.security_context.__class__.__name__, 'level%s' % index)} title="${tag.title}">
        ${tag.title_short}
      </a>
    </li>
    %endfor
  %endif

  %if breadcrumbs:
    <%
       if len(breadcrumbs) == 3:
         ellipsis = [15, 15, 25]
       elif len(breadcrumbs) == 2:
         ellipsis = [20, 40]
       else:
         ellipsis = [50]
    %>
    %for ind, breadcrumb in enumerate(breadcrumbs):
       <%
          cls = 'first' if ind == 0 and not c.object_location else 'second'
       %>
       <li class="${cls}">
         %if ind != len(breadcrumbs) - 1:
           <a title="${breadcrumb.get('title')}" href="${breadcrumb.get('link')}">
             ${h.ellipsis(breadcrumb.get('title'),ellipsis[ind])}
           </a>
         %else:
           ${h.ellipsis(breadcrumb.get('title'),ellipsis[ind])}
         %endif
       </li>
    %endfor
  %endif
  </ul>
  %endif
</div>
</%def>

<%def name="anonymous_header()">
<ul id="socialLinks">
  <li id="blogLink"><a href="${_('ututi_blog_url')}">${_(u'„Ututi“ blog')}</a></li>
  <li id="twitterLink"><a href="${_('ututi_twitter_url')}">${_(u'„Ututi“ on twitter')}</a></li>
  <li id="facebookLink"><a href="${_('ututi_facebook_url')}">${_(u'„Ututi“ on Facebook')}</a></li>
</ul>
<form method="post" id="loginForm" action="${url('/login')}">
  <fieldset>
    <input type="hidden" name="came_from" value="${request.params.get('came_from', request.url)}" />
    <legend class="a11y">${_('Join!')}</legend>
    <label class="textField"><span class="overlay">${_('Email')}:</span><input type="text" name="login" value="${request.params.get('login')}"/><span class="edge"></span></label>
    <label class="textField"><span class="overlay">${_('Password')}</span><input type="password" name="password" /><span class="edge"></span></label>
    <button class="btn" type="submit" value="${_('Login')}"><span>${_('Login')}</span></button><br />
    <label id="rememberMe"><input type="checkbox"> ${_('remember me')}</label><br />
    <a href="${url(controller='home', action='pswrecovery')}">${_('forgotten password?')}</a>
  </fieldset>
  <script type="text/javascript">
    $(window).load(function() {
    $(".textField .overlay").labelOver('over');
    });
  </script>

</form>
${self.anonymous_menu()}
</%def>

<%def name="loggedin_header(user)">
<form id="searchForm" action="${url(controller='profile', action='search')}">
    <fieldset>
        <legend class="a11y">${_('Search')}</legend>
        <label class="textField">
          <span class="a11y">${_('Search text')}</span>
          <input type="text" name="text"/>
          <span class="edge"></span>
        </label>
        ${h.input_submit(_('search_'))}
    </fieldset>
</form>
<p class="a11y">${_('Main menu')}</p>
<div class="head-nav">
  <ul>
    <li><a href="${url(controller='profile', action='home')}">${_('Home')}</a></li>
    <li><a href="${url(controller='profile', action='browse')}">${_('Browse')}</a></li>
    <li class="expandable group-nav">
      <span>${_('Groups')}</span>
      <div>
        <ul>
          %for mship in user.memberships:
            <li>
              <a href="${url(controller='group', action='index', id=mship.group.group_id)}"
                 ${h.trackEvent(None, 'group_home', 'top_menu')} title="${mship.group.title}">
                ${h.ellipsis(mship.group.title, 18)}
              </a>
            </li>
          %endfor
          <li class="action"><a href="${url(controller='group', action='group_type')}">${_('Create group')}</a></li>
        </ul>
      </div>
    </li>
    <li><a href="${url(controller='community', action='index')}">${_('Community')}</a></li>
  </ul>
</div>
<p class="a11y">${_('User menu')}</p>
<div class="loggedin-nav" id="personal-data">
    <ul>
        <li><a href="#" id="feedback-link">${_('feedback')}</a></li>
##      <li><a href="#"><strong>inbox (3)</strong></a></li>
        <li class="expandable profile-nav">
            <span class="fullname">${user.fullname}</span>
            <div>
                <ul>
                    <li class="action"><a href="${url(controller='profile', action='edit')}">${_('Settings')}</a></li>
                    <li class="action"><a href="${url(controller='user', action='index', id=user.id)}">${_('Public profile')}</a></li>
                </ul>
            </div>
        </li>
        <li><a href="${url(controller='home', action='logout')}">${_('log out')}</a></li>
    </ul>
</div>

<script type="text/javascript">
    // nav ul li expandable
    $('ul li.expandable').toggle(function() {
        $(this).addClass('expanded').find('div:last-child ul').show();
    }, function(){
        $(this).removeClass('expanded').find('div:last-child ul').hide();
    }).click(function(){ // remove selection
        if(document.selection && document.selection.empty) {
            document.selection.empty() ;
        } else if(window.getSelection) {
            var s = window.getSelection();
            if(s && s.removeAllRanges)
                s.removeAllRanges();
        }
    }).find('li a').click(function(ev){
        ev.preventDefault();
        window.location.href = $(this).attr('href');
    });
</script>
</%def>

<%def name="flash_messages()">
<div id="flash-messages">
  % if c.serve_file:
  <iframe style="display: none;" src="${c.serve_file.url()}"> </iframe>
  % endif

  <% messages = h.flash.pop_messages() %>
  % for message in messages:
  <div class="flash-message">
      <span class="close-link hide-parent">
        ${h.image('/img/icons/bigX_15x15.png', alt=_('Close'))}
      </span>
      <span>${h.literal(unicode(message))}</span>
  </div>
  % endfor
  ${invitation_messages(c.user)}
  ${request_messages(c.user)}
  ${confirmation_messages(c.user)}
</div>
</%def>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xml:lang="lt" xmlns="http://www.w3.org/1999/xhtml" lang="lt">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

    <script type="text/javascript">
      var lang = '${c.lang}';
    </script>

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

    ${h.stylesheet_link(h.path_with_hash('/newstyle.css'))}
    ${h.javascript_link('/javascript/jquery-1.3.2.min.js')}
    ${h.javascript_link('/javascript/ajaxupload.3.5.js')}
    ${h.javascript_link('/javascript/jquery.qtip.min.js')}
    ${h.javascript_link('/javascript/tooltips.js')}
    ${h.javascript_link(h.path_with_hash('/javascript/expand.js'))}
    ${h.javascript_link(h.path_with_hash('/javascript/hide_parent.js'))}
    ${h.javascript_link(h.path_with_hash('/javascript/forms.js'))}
    ${self.head_tags()}
    <title>
      ${self.title()} - ${_('UTUTI')}
    </title>
  </head>
  <body class="${self.body_class()}">
  % if c.serve_file:
  <iframe style="display: none;" src="${c.serve_file.url()}"> </iframe>
  % endif

    <div id="wrap">
      <div id="widthLimiter">
        ${breadcrumbs(c.breadcrumbs)}
        %if c.user is None:
          ${self.anonymous_header()}
        %else:
          ${self.loggedin_header(c.user)}
        %endif

        ${next.body()}
      </div>
      <div class="push"></div>
    </div>

    <div id="footer">
      <%
         nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '')
      %>
      <p>Copyright © <a href="${_('ututi_link')}">${_(u'UAB „UTUTI“')}</a></p>
      <ul>
        <li><a ${nofollow} href="${url(controller='home', action='about')}">${_('About ututi')}</a></li>
        <li><a ${nofollow} href="${_('ututi_blog_url')}">${_('U-blog')}</a></li>
        <li><a ${nofollow} href="${url(controller='home', action='terms')}">${_('Terms of use')}</a></li></ul>
    </div>
    %if c.lang in ['lt', 'en']:
    ${h.javascript_link('/javascript/uservoice.js')|n}
    <script type="text/javascript">
      var uservoiceOptions = {
        key: 'ututi',
        host: 'ututi.uservoice.com',
        forum: '26068',
        lang: 'en',
        showTab: false
      };
      function _loadUserVoice() {
        var s = document.createElement('script');
        s.src = ("https:" == document.location.protocol ? "https://" : "http://") + "cdn.uservoice.com/javascripts/widgets/tab.js";
        document.getElementsByTagName('head')[0].appendChild(s);
      }
      _loadSuper = window.onload;
      window.onload = (typeof window.onload != 'function') ? _loadUserVoice : function() { _loadSuper(); _loadUserVoice(); };
      $('#feedback-link').click(function() {
        UserVoice.Popin.show(uservoiceOptions); return false;
      });
    </script>
    %else:
      ${h.javascript_link('/javascript/sugester.js')|n}
    %endif

  </body>
</html>

<%def name="rounded_block(class_='', id=None)">
<div class="portlet portletSmall ${class_}"
     %if id is not None:
       id="${id}"
     %endif
>
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>

  ${caller.body()}
</div>
</%def>
