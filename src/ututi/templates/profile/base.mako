<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="pageTitle">${self.pagetitle()}</h1>
%endif

<%
  ## Now this is a bit ugly, but these tabs will go away soon anyhow.
  show_tabs = not c.user.is_teacher
%>

%if c.action and show_tabs:
<ul class="moduleMenu">
  <li class="${'current' if c.action == 'home' else ''}"><a href="${url(controller='profile', action='home')}">${_('Start')}<span class="edge"></span></a></li>
  <li class="${'current' if c.action == 'feed' else ''}"><a href="${url(controller='profile', action='feed')}">${_("News feed")}
      	  <% unread_feed_messages = c.user.unread_feed_messages() %>
          %if unread_feed_messages:
      	     (${unread_feed_messages})
          %endif
          <span class="edge"></span></a></li>
  <li><a id='inbox-link' href="${url(controller='messages', action='index')}">
          <% unread_messages = c.user.unread_messages() %>
          %if unread_messages:
  	     <strong>${_("Inbox")} (${unread_messages})</strong>
	  %else:
	     ${_("Inbox")}
	  %endif
	  <span class="edge"></span></a></li>
</ul>
%endif
${next.body()}
