<%def name="title()">
${_('student information online')}
</%def>

<%def name="head_tags()">
</%def>

<%def name="personal_block()">
%if c.user:
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
  <span>
    ${h.link_to(_("Log out"), url('/logout'))}
  </span>
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
<form method="post" id="login_form" action="${url('/dologin')}">
  %if request.GET.get('came_from'):
  <input type="hidden" name="came_from" value="${request.GET.get('came_from')}" />
  %endif

  <div class="form-field overlay">
    <label for="login" class="small">${_('Email')}</label>
    <input type="text" size="20" id="login" name="login" class="small"/>
  </div>
  <div class="form-field overlay">
    <label for="password" class="small">${_('Password')}</label>
    <input type="password" size="20" name="password" id="password" class="small"/>
  </div>
  <div class="form-field">
    <span class="btn"><input class="submit small" type="submit" name="join" value="Login" /></span>
  </div>
  <div class="form-field">
    <a class="small-link small XXX" href="#">Forgotten password?</a>
  </div>
</form>
<script type="text/javascript">
  $(".overlay label").labelOver('over');
</script>
%endif
</%def>

<%def name="portlets()">
</%def>

<%def name="portlet(id, portlet_class='')">
<div class="sidebar-block ${portlet_class}" id="${id}">
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
  %if breadcrumbs:
<ul id="breadcrumbs">
  <%
     first_bc = True
     %>
  %for breadcrumb in breadcrumbs:
  %if not first_bc:
  <li>
    %else:
  <li class="no-bullet">
    <%
       first_bc = False
       %>
    %endif
    %if isinstance(breadcrumb, dict):

    <a class="breadcrumb" title="${breadcrumb.get('title')}" href="${breadcrumb.get('link')}">
      ${breadcrumb.get('title') | h.ellipsis}
    </a>
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
          <% messages = h.flash.pop_messages() %>
          % for message in messages:
          <div class="flash-message"><span class="close-link hide-parent">${_('Close')}</span><span>${message}</span></div>
          % endfor

          %if c.user:
          %for invitation in c.user.invitations:
          <div class="flash-message">
            <span>
              ${_(u"%(author)s has sent you an invitation to group %(group)s. Do You want to become a member of this group?") % dict(author=invitation.author.fullname, group=invitation.group.title)}
            </span>
            <br/>
            <form method="post"
                  action="${url(controller='group', action='invitation', id=invitation.group.group_id)}"
                  id="${invitation.group.group_id}_invitation_reject"
                  class="inline-form">
              <div style="display: inline;">
                <input type="hidden" name="action" value="reject"/>
                <input type="hidden" name="came_from" value="${request.url}"/>
                <span class="btn">
                  <input type="submit" name="invitation_reject" value="${_('Reject')}"/>
                </span>
              </div>
            </form>

            <form method="post"
                  action="${url(controller='group', action='invitation', id=invitation.group.group_id)}"
                  id="${invitation.group.group_id}_invitation_accept"
                  class="inline-form">
              <div style="display: inline;">
                <input type="hidden" name="action" value="accept"/>
                <input type="hidden" name="came_from" value="${request.url}"/>
                <span class="btn">
                  <input type="submit" name="invitation_accept" value="${_('Accept')}"/>
                </span>
              </div>
            </form>

          </div>
          %endfor
          %endif

          ${self.body()}
          <br style="clear: both;"/>
        </div>

      </div>

      <div id="footer" class="small">
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
