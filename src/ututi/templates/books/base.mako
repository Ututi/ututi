<%namespace file="/sections/messages.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>
<%namespace file="/portlets/books.mako" import="*"/>

<%def name="title()">
${_('Learning books market')}
</%def>

<%def name="head_tags()">
${h.stylesheet_link(h.path_with_hash('/books.css'))}
</%def>


<%def name="body_class()">
</%def>

<%def name="anonymous_header()">
${self.anonymous_menu()}
</%def>

<%def name="portlets()">
${books_menu(c.selected_books_department)}
</%def>

<%def name="breadcrumbs(breadcrumbs)">
</%def>

<%def name="main_menu()">
<p class="a11y">${_('Main menu')}</p>
<div class="head-nav">
  <ul>
    <li id="ulogo"><a rel="nofollow" href="/books" title="Ututi">
        <img src="/images/books/ubooks-logo.png" />
    </a></li>
    <li><a href="${url(controller='books', action='index')}">${_('Home')}</a></li>
    <li><a href="${url(controller='books', action='about')}">${_('About U-Books')}</a></li>
    <li><a class="orange" href="${url(controller='books', action='add')}">${_('Upload a Book')}</a></li>
  </ul>
</div>
</%def>

<%def name="anonymous_menu()">
${local.main_menu()}
<p class="a11y">${_('Login')}</p>
<div class="loggedin-nav">
    <ul>
      <li>
        <a href="${url(controller='home', action='login', context_type='books_login', came_from=url.current())}">
          ${_('Login')}
        </a>
      </li>
      <li>
        <a href="${url(controller='home', action='login', context_type='books_register', came_from=url.current())}">
          ${_('Register')}
        </a>
      </li>
    </ul>
</div>
</%def>

<%def name="loggedin_menu()">
${local.main_menu()}
<div class="loggedin-nav" id="personal-data">
    <ul>
      <li>${h.link_to(_("My books"), url(controller="books", action="my_books"))}</li>
      <li class="expandable profile-nav">
        <span class="fullname">${c.user.fullname}</span>
        <div>
          <ul>
            <li class="action"><a href="${url(controller='profile', action='edit')}">${_('Settings')}</a></li>
            <li class="action"><a href="${url(controller='user', action='index', id=c.user.id)}">${_('Public profile')}</a></li>
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
      ${h.image('/img/icons/bigX_15x15.png', alt=_('No, thanks'))}
    </a>
  </div>
</div>
%endif

</div>
</%def>



<%def name="loggedin_header()">
  ${self.loggedin_menu()}
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

    ${h.stylesheet_link(h.path_with_hash('/style.css'))}
    ${h.stylesheet_link(h.path_with_hash('/fixed.css'))}
    ${h.javascript_link('/javascript/jquery-1.4.4.min.js')}
    ${h.javascript_link('/javascript/ajaxupload.3.5.js')}
    ${h.javascript_link('/javascript/jquery.qtip.min.js')}
    ${h.javascript_link('/javascript/tooltips.js')}
    ${h.javascript_link('/javascript/jquery.blockUI.js')}
    ${h.javascript_link('/javascript/jquery-ui-1.8.6.custom.min.js')|n}
    ${h.stylesheet_link(h.path_with_hash('/jquery-ui-1.8.6.custom.css'))}
    ${h.javascript_link('/javascript/jquery.form.js')|n}
    ${h.javascript_link(h.path_with_hash('/javascript/expand.js'))}
    ${h.javascript_link(h.path_with_hash('/javascript/hide_parent.js'))}
    ${h.javascript_link(h.path_with_hash('/javascript/forms.js'))}
    ${self.head_tags()}
    <title>
      ${self.title()} - ${_('uBooks')}
    </title>
  </head>
  <body class="${self.body_class()}">
    %if c.testing:
    <div style="width: 200px; position: absolute; top: 0; left: 0; z-index: 1000; background: #f7ff00; padding: 5px;" id="test_warning">
      ${_('This is a testing version - this is just a copy of the information! Changes you make will not be persisted!')}
    </div>
    <script type="text/javascript">
      $(document).ready(function(){$('#test_warning').click(function(){$(this).hide();})});
    </script>
    %endif
  % if c.serve_file:
  <iframe style="display: none;" src="${c.serve_file.url()}"> </iframe>
  % endif

    <div id="wrap">
      <div id="widthLimiter">
        %if c.user is None:
          ${self.anonymous_header()}
        %else:
          ${self.loggedin_header()}
        %endif

        <div id ="books-container">
          <div id="aside">
            ${self.portlets()}
          </div>
          <div id="mainContent">
            ${self.flash_messages()}
            ${next.body()}
          </div>
        </div>

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
        <li><a ${nofollow} href="${url(controller='home', action='terms')}">${_('Terms of use')}</a></li>
        <li><a href="#" id="feedback-link">${_('Feedback')}</a></li>
      </ul>
      <div class="folow-us-icons">
      <a href="${config.get('folow_us_facebook', 'http://www.facebook.com/ututi')}">
        ${h.image('/img/social/facebook_32.png', alt=_('Follow us on Facebook'))}
      </a>
      <a href="${config.get('folow_us_twitter', 'http://twitter.com/ututi')}">
        ${h.image('/img/social/twitter_32.png', alt=_('Follow us on Twitter'))}
      </a>
      <a href="${config.get('folow_us_ublog', 'http://blog.ututi.lt')}">
        ${h.image('/img/social/ublog_32.png', alt=_('Read about us in blog'))}
      </a>

      </div>
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

    <div id="fb-root"></div>
    %if c.lang == 'lt':
      <script src="http://connect.facebook.net/lt_LT/all.js"></script>
    %elif c.lang == 'pl':
      <script src="http://connect.facebook.net/pl_PL/all.js"></script>
    %else:
      <script src="http://connect.facebook.net/en_US/all.js"></script>
    %endif
    <script>
      FB.init({appId: '${c.facebook_app_id}', status: true,
          cookie: true, xfbml: true, channelUrl: '${url(controller='home', action='fbchannel', qualified=True)}'});
    </script>

  </body>
</html>

