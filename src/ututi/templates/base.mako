<%namespace file="/sections/messages.mako" import="*"/>

<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="personal_block()">
%if c.user:
<div id="personal-menu">
  <div class="item">
    ${h.link_to(_("Log out"), url('/logout'))}
  </div>
  <div class="click2show item">
    <span class="click title">${_('Groups')}</span>
    <ul class="expanding-menu show">
      <li class="top"><div>&nbsp;</div></li>
      %for mship in c.user.memberships:
        <li>
          <div>
            <a href="${url(controller='group', action='home', id=mship.group.group_id)}" title="${mship.group.title}">
              ${h.ellipsis(mship.group.title, 20)}
            </a>
          </div>
        </li>
      %endfor
      <li class="bottom"><div><a href="${url(controller='group', action='add')}" title="${_('Create a new group')}">${_('New group')}</a></div></li>
    </ul>
  </div>
  <div class="click2show item">
    <span class="click title">${_('Home')}</span>
    <ul class="expanding-menu show">
      <li class="top"><div>&nbsp;</div></li>
      <li><div><a href="${url(controller='profile', action='home')}">${_("What's new?")}</a></div></li>
      <li><div><a href="${url(controller='profile', action='index')}">${_("Profile")}</a></div></li>
      <li class="bottom"><div><a href="${url(controller='search', action='index')}">${_("Search")}</a></div></li>
    </ul>
  </div>
</div>

<div class="personal-info">
  <div class="personal-logo">
    % if c.user.logo is not None:
    <img src="${url(controller='user', action='logo', id=c.user.id, width=60, height=60)}" alt="logo" />
    % else:
    <a href="${url(controller='profile', action='edit')}" title="${_('Upload your personal logo')}">
      ${h.image('/images/user_logo_45x60.png', alt='logo')|n}
    </a>
    % endif
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
    <div class="input-rounded"><div>
        <input type="text" size="20" id="login" name="login" class="small" value="${request.params.get('login')}" />
    </div></div>
  </div>
  <div class="form-field overlay">
    <label for="password" class="small">${_('Password')}</label>
    <div class="input-rounded"><div>
        <input type="password" size="20" name="password" id="password" class="small"/>
    </div></div>
  </div>
  <div class="form-field">
    <span class="btn"><input class="submit small" type="submit" name="join" value="Login" /></span>
  </div>
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
</%def>

<%def name="breadcrumbs(breadcrumbs)">
<div id="breadcrumb-container">
  %if breadcrumbs:
  <a href="${url('/')}" title="home" id="ulogo">
    ${h.image('/images/logo_small.png', alt='logo')|n}
  </a>
  %else:
  <a href="${url('/')}" title="home" id="ulogo">
    ${h.image('/images/logo.png', alt='logo')|n}
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
      <div class="title">${tag.title_short}</div>
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
        <a class="breadcrumb" title="${breadcrumb.get('title')}" href="${breadcrumb.get('link')}">
          ${breadcrumb.get('title') | h.ellipsis}
        </a>
      </div>
      %else:
      <%
         selected = h.selected_item(breadcrumb)
         %>

      <ul class="breadcrumb_dropdown">
        <li class="active">
          <div>
            <span>${selected.get('title') | h.ellipsis}</span>
          </div>
        </li>
        %for item in h.marked_list(breadcrumb):
        <%
           if item.get('last_item', False):
               cls = 'last'
           else:
               cls = 'alternative'
           %>
        <li class="${cls}">
          <div>
            <a class="subbreadcrumb" title="${item.get('title')}" href="${item.get('link')}">${item.get('title') | h.ellipsis}</a>
          </div>
        </li>
        %endfor
      </ul>
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
    ${h.stylesheet_link('/stylesheets/style.css')|n}
    ${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
    ${h.javascript_link('/javascripts/expand.js')|n}
    ${h.javascript_link('/javascripts/hide_parent.js')|n}
    <!-- Load TinyMCE -->
    ${h.javascript_link('/javascripts/tiny_mce/jquery.tinymce.js')|n}
    <script type="text/javascript">
      $().ready(function() {
      $('textarea.tinymce').tinymce({
      // Location of TinyMCE script
      script_url : '${url('/javascripts/tiny_mce/tiny_mce.js')}',

      // General options
      theme : "advanced",
      plugins : "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",

      // Theme options
      theme_advanced_buttons1 : "bold,italic,underline,strikethrough,formatselect,fontsizeselect,tablecontrols,|,hr,sub,sup,|,media,advhr",
      theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,code",
      theme_advanced_buttons3 : "",
      theme_advanced_buttons4 : "",
      theme_advanced_toolbar_location : "top",
      theme_advanced_toolbar_align : "left",
      theme_advanced_statusbar_location : "bottom",
      theme_advanced_resizing : true,

      // Example content CSS (should be your site CSS)
      content_css : "stylesheets/style.css",

      // Drop lists for link/image/media/template dialogs
      template_external_list_url : "lists/template_list.js",
      external_link_list_url : "lists/link_list.js",
      external_image_list_url : "lists/image_list.js",
      media_external_list_url : "lists/media_list.js",

      extended_valid_elements : "iframe[src|width|height|name|align]",

      });
      });
    </script>
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
          ${self.personal_block()}
        </div>

        ${breadcrumbs(c.breadcrumbs)}
      </div>

      <div id="content">
        ${self.portlets()}

        <div class="inside" id="page-content">
          <div id="flash-messages">
            <% messages = h.flash.pop_messages() %>
            % for message in messages:
            <div class="flash-message"><span class="close-link hide-parent">${_('Close')}</span><span>${message}</span></div>
            % endfor
            ${invitation_messages(c.user)}
            ${request_messages(c.user)}
          </div>
          ${self.body()}
          <br style="clear: both;"/>
        </div>

      </div>

      <div id="footer" class="small">
        Copyright <a href="http://www.nous.lt">UAB „Nous“</a>
        <div id="footer-links">
          <a href="http://blog.ututi.lt/apie">${_('Apie Ututi')}</a> |
          <a href="http://blog.ututi.lt">${_('U-blog')}</a> |
          <a href="${url(controller='home', action='terms')}">${_('Terms of use')}</a>
        </div>

      </div>
    </div>
<!--
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
-->
  </body>
</html>
