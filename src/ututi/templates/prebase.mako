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

<%def name="anonymous_header()">
  <% nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '') %>
  <a id="logo" href="${url('/')}"><img src="/img/Ututi_logo_big.png" alt="Ututi" title="Ututi"/></a>
  <span id="slogan">${_("Bringing students and teachers together")}</span>
  <ul id="nav">
    <li class="header-links"><a href="${url('/features')}">${_('What is Ututi?')}</a></li>
    <li class="header-links"><a href="${url('/contacts')}">${_('Contact us')}</a></li>
    <li class="header-links" id="login-link"><a ${nofollow} href="${url(controller='home', action='login')}">${_('Login')}</a></li>
  </ul>
</%def>

<%def name="loggedin_header()">
  <div id="logo">
    <a href="${url('/')}"><img src="/img/Ututi_logo.png" alt="Ututi" title="Ututi" /></a>
  </div>
  <div id="top-panel">
    <ul id="head-nav">
      <li id="nav-home"><a href="${url(controller='profile', action='home')}">${_('Home')}</a></li>
      <li id="nav-university"><a href="${c.user.location.url()}">${_('My University')}</a></li>
      <li id="nav-catalog"><a href="${url(controller='profile', action='browse')}">${_('Catalog')}</a></li>
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
  %if c.user is None:
    ${self.anonymous_header()}
  %else:
    ${self.loggedin_header()}
  %endif
</%def>

<%def name="footer()">
  <% nofollow = h.literal(request.path != '/' and  'rel="nofollow"' or '') %>
  <div class="column left">
    <form id="language-switch-form" action="${url('switch_language')}">
      <input name="came_from" type="hidden" value="${request.url}" />
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
  <div class="column middle">Copyright © <a href="${url('frontpage')}">${_(u'„UTUTI Ltd.“')}</a></div>
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

    ${h.stylesheet_link(h.path_with_hash('/reset.css'))}
    ${h.stylesheet_link(h.path_with_hash('/style.css'))}
    ${h.stylesheet_link(h.path_with_hash('/layout.css'))}
    ${h.stylesheet_link(h.path_with_hash('/fixed.css'))}
    ${h.stylesheet_link(h.path_with_hash('/portlets.css'))}
    ${h.stylesheet_link(h.path_with_hash('/widgets.css'))}
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
    </style>
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

    <div id="header" class="anonymous">
      <div id="header-inner">
        ${self.header()}
      </div>
    </div>

    ${next.body()}

    <div id="footer">
      ${self.footer()}
    </div>

    %if c.lang in ['lt', 'en', 'pl']:
    ${h.javascript_link('/javascript/uservoice.js')|n}
    <script type="text/javascript">
      %if c.lang in ['lt', 'en']:
      var uservoiceOptions = {
        key: 'ututi',
        host: 'ututi.uservoice.com',
        forum: '26068',
        lang: 'en',
        showTab: false
      };
      %else:
      var uservoiceOptions = {
        key: 'ututipl',
        host: 'ututipl.uservoice.com',
        forum: '69159',
        lang: 'pl',
        showTab: false
      };
      %endif
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
    %endif

    <script src="/javascript/jquery.blockUI.js"></script>
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
