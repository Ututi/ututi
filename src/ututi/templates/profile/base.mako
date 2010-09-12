<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="pagetitle()">
${_('Home')}
</%def>

<h1 class="pageTitle">${self.pagetitle()}</h1>
%if c.action:
<ul class="moduleMenu">
  <li class="${'current' if c.action == 'home' else ''}"><a href="${url(controller='profile', action='home')}">${_('Start')}<span class="edge"></span></a></li>
  <li class="${'current' if c.action == 'feed' else ''}"><a href="${url(controller='profile', action='feed')}">${_("What's new?")}
<% unread_feed_messages = c.user.unread_feed_messages() %>
%if unread_feed_messages:
  (${unread_feed_messages})
%endif
<span class="edge"></span></a></li>
  <li><a href="${url(controller='messages', action='index')}">${_("Inbox")}<span class="edge"></span></a></li>
</ul>
%endif
${next.body()}
