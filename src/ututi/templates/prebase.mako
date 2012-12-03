<%namespace file="/sections/messages.mako" import="*"/>

<%def name="title()">
${_('Private social networks for universities')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="css()">
</%def>

<%def name="body_class()">
</%def>

<%def name="anonymous_themed_header(theme)">
  <% nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '') %>
  <a id="logo" href="${url('/')}"><img src="${theme.url(action="header_logo", size=55)}" alt="VUtuti" title="VUtuti"/></a>
  <span id="slogan">${theme.location_title_or_slogan}</span>
  <ul id="nav">
    <li class="header-links"><a href="${url('/features')}">${_('What is VUtuti?')}</a></li>
    <li class="header-links"><a href="${url('/contacts')}">${_('Contact us')}</a></li>
    <li class="header-links" id="login-link"><a ${nofollow} href="${url(controller='home', action='login')}">${_('Login')}</a></li>
  </ul>
</%def>

<%def name="anonymous_header()">
  <% nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '') %>
  <a id="logo" href="${url('/')}"><img src="${url('/img/mif_27.png')}" alt="VUtuti" title="VUtuti"/></a>
  <span id="slogan">${_("VU MIF social network")}</span>
  <ul id="nav">
    <li class="header-links"><a href="${url('/features')}">${_('What is VUtuti?')}</a></li>
    <li class="header-links"><a href="${url('/contacts')}">${_('Contact us')}</a></li>
    <li class="header-links" id="login-link"><a ${nofollow} href="${url(controller='home', action='login')}">${_('Login')}</a></li>
  </ul>
</%def>

<%def name="loggedin_header()">
  <div id="logo">
    %if c.theme:
      <div id="branded-logo" style="background-image: url('${c.theme.url(action="header_logo", size=25)}'); color: #${c.theme.header_color}">
        ${c.theme.header_text}
      </div>
    %else:
      <a href="${url('/')}"><img src="${url('/img/mif_25.png.png')}" alt="VUtuti" title="VUtuti" /></a>
    %endif
  </div>
  <div id="top-panel">
    <ul id="head-nav">
      <li id="nav-home"><a href="${url(controller='profile', action='home')}">${_('Home')}</a></li>
      <li id="nav-university"><a href="${c.user.location.url()}">${_('My University')}</a></li>
    </ul>
    <form id="search-form" action="${url(controller='profile', action='search')}">
      <label>
        <span class="a11y">${_('Search text')}</span>
        <input type="text" name="text"/>
      </label>
      ${h.input_submit(_('search_'))}
    </form>
    <ul id="user-menu">
      <li class="expandable profile-nav">
        <div class="fullname">${c.user.fullname}</div>
        <div class="expandable-items">
          <ul>
            <li class="action"><a href="${url(controller='profile', action='settings')}">${_('Account settings')}</a></li>
            <li class="action"><a href="${url(controller='profile', action='edit')}">${_('Edit profile')}</a></li>
            <li class="action"><a href="${c.user.url()}">${_('Public profile')}</a></li>
            <li class="action"><a href="${url(controller='home', action='logout')}">${_('Logout')}</a></li>
          </ul>
        </div>
      </li>
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

<%def name="header()">
  %if c.user is None and c.theme:
    ${self.anonymous_themed_header(c.theme)}
  %elif c.user is None:
    ${self.anonymous_header()}
  %else:
    ${self.loggedin_header()}
  %endif
</%def>

<%def name="footer()">
  <% nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '') %>
  <div class="column left">
    <%
    if hasattr(c, 'location'):
      lang_switch_action = c.location.url(action='switch_language')
    else:
      lang_switch_action = url('switch_language')
    %>
    <form id="language-switch-form" action="${lang_switch_action}">
      <input name="came_from" type="hidden" value="${url.current()}" />
      <label for="language-box">${_("Language:")}</label>
      ${h.select('language', c.lang, h.get_languages(), id='language-box')}
      ${h.input_submit(_('Select'))}
      <script type="text/javascript">
      $(document).ready(function() {
          $('#language-box').change(function() {
              $(this).closest('form').submit();
          });
          $('#language-box').val(lang);
      });
      </script>
    </form>
  </div>
  <div class="column middle">Copyright © <a href="${url('frontpage')}">${_('Vilnius University')}</a></div>
  <div class="column right link-color">
    <a ${nofollow} href="${url(controller='home', action='about')}">${_('About')}</a>
    |
    <a ${nofollow} href="${url(controller='home', action='terms')}">${_('Terms')}</a>
    |
    <a href="${url(controller='home', action='contacts')}">${_('Contact Us')}</a>
    |
    <a href="#" id="feedback-link">${_('Feedback')}</a>
  </div>
</%def>

<%def name="flash_messages()">
<div id="flash-messages">
  % if c.serve_file:
  <iframe style="display: none;" src="${c.serve_file.url(attachment=1)}"> </iframe>
  % endif

  <% messages = h.flash.pop_messages() %>
  % for message in messages:
  <div class="flash-message">
      <span class="close-link hide-parent">
        ${h.image('/img/icons.com/close.png', alt=_('Close'))}
      </span>
      <span class="flash-message-content">${h.literal(unicode(message))}</span>
  </div>
  % endfor
  ${invitation_messages(c.user)}
  ${request_messages(c.user)}
  ${confirmation_messages(c.user)}
  ${unverified_teacher_message(c.user)}

%if c.user_notification:
<div class="user-notification flash-message">
  <div>
    ${c.user_notification.content|n}
  </div>
  <div class="user-notification-response">
    <a class="close-link" href='#' onclick="
       $.ajax({
         url:'${url(controller = 'notifications', action='set_notification_as_viewed', id=c.user_notification.id, user_id = c.user.id)}',
         success: function(){
           $('.user-notification').fadeOut();
         }
       })">
      ${h.image('/img/icons.com/close.png', alt=_('No, thanks'))}
    </a>
  </div>
</div>
%endif

</div>
</%def>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xml:lang="lt" xmlns="http://www.w3.org/1999/xhtml" lang="lt">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

    <script type="text/javascript">
      var lang = '${c.lang}';
    </script>

    ## Break out of iframes automatically.
    <script type="text/javascript">
      if (top.location!= self.location) {
          top.location = self.location.href;
      }
    </script>

    %if c.google_tracker:
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
    %endif
    ${h.stylesheet_link(h.path_with_hash('/reset.css'))}
    ${h.stylesheet_link(h.path_with_hash('/style.css'))}
    ${h.stylesheet_link(h.path_with_hash('/layout.css'))}
    ${h.stylesheet_link(h.path_with_hash('/fixed.css'))}
    ${h.stylesheet_link(h.path_with_hash('/portlets.css'))}
    ${h.stylesheet_link(h.path_with_hash('/widgets.css'))}
    ${h.stylesheet_link(h.path_with_hash('/colorbox.css'))}
    <!--[if IE]>
    ${h.stylesheet_link(h.path_with_hash('/ie.css'))}
    <![endif]-->
    ${h.javascript_link('/javascript/jquery-1.4.4.min.js')}
    ${h.javascript_link('/javascript/ajaxupload.3.5.js')}
    ${h.javascript_link('/javascript/jquery.qtip.min.js')}
    ${h.javascript_link('/javascript/tooltips.js')}
    ${h.javascript_link('/javascript/jquery.blockUI.js')}
    ${h.javascript_link('/javascript/jquery-ui-1.8.10.custom.min.js')|n}
    ${h.stylesheet_link(h.path_with_hash('/jquery-ui-1.8.10.custom.css'))}
    ${h.javascript_link('/javascript/jquery.form.js')|n}
    ${h.javascript_link(h.path_with_hash('/javascript/expand.js'))}
    ${h.javascript_link(h.path_with_hash('/javascript/hide_parent.js'))}
    ${h.javascript_link(h.path_with_hash('/javascript/forms.js'))}
    ${h.javascript_link('/javascript/js-alternatives.js')|n}
    ${self.head_tags()}
    <style type="text/css">
      ${self.css()}
      %if c.theme is not None:
      #header {
        background-color: #${c.theme.header_background_color};
      }

      .anonymous #header #slogan {
        color: #${c.theme.header_color};
      }

      .anonymous .themed#header,
      .anonymous .themed#header-inner {
        height: 90px;
      }

      .anonymous .themed#header {
        border-bottom: #bbb solid 1px;
      }

      .anonymous .themed#header #nav {
        display: none;
      }

      .anonymous .themed#header #slogan {
        position: absolute;
        left: 100px;
        bottom: 10px;
        font-size: 20px;
      }
      %endif
    </style>
<!--[if IE 7]>
    <script type="text/javascript">
        $(function () {
            $('button.submit').click(function () {
                $(this).closest('form').submit();
            });
        });
    </script>
<![endif]-->

    <title>
      ${self.title()} - ${_('UTUTI')}
    </title>
  </head>
  <body class="${self.body_class()} ${'anonymous' if c.user is None else ''}">
    %if c.testing:
    <div style="width: 200px; position: absolute; top: 0; left: 0; z-index: 1000; background: #f7ff00; padding: 5px;" id="test_warning">
      ${_('This is a testing version - this is just a copy of the information! Changes you make will not be persisted!')}
    </div>
    <script type="text/javascript">
      $(document).ready(function(){$('#test_warning').click(function(){$(this).hide();})});
    </script>
    %endif

    <div id="header" class="${'themed' if c.theme else ''}">
      <div id="header-inner">
        ${self.header()}
      </div>
    </div>

    ${next.body()}

    <div id="footer" class="clear footer-frontpage">
      <div id="footer-inner">
        ${self.footer()}
      </div>
    </div>
    <div id="loading" style="display: none">
        ${_('Loading...')}
    </div>
    <script>
        function show_loading_message() {
            $.blockUI({
                message: $('#loading'),
                css: {
                    border: 'none',
                    padding: '25px',
                    backgroundColor: '#000',
                    '-webkit-border-radius': '10px',
                    '-moz-border-radius': '10px',
                    'font-size': '26px',
                    opacity: .5,
                    color: '#fff'
                }
            });
        }
    </script>
  </body>
</html>


<%def name="rounded_block(class_='', id=None, style=None)">
<div class="rounded-block ${class_}"
     %if id is not None:
       id="${id}"
     %endif

     %if style is not None:
       style="${style}"
     %endif
>
  <div class="ctl"></div>
  <div class="ctr"></div>
  <div class="cbl"></div>
  <div class="cbr"></div>
  ${caller.body()}
</div>
</%def>

<%def name="normal_block(class_='', id=None, style=None)">
<div class="normal-block ${class_}"
     %if id is not None:
       id="${id}"
     %endif

     %if style is not None:
       style="${style}"
     %endif
> 
  ${caller.body()}
</div>
</%def>
