<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="pagetitle()">
${_('Home')}
</%def>

<h1 class="pageTitle">${self.pagetitle()}</h1>

<ul class="moduleMenu">
  <li><a href="${url(controller='profile', action='home')}">${_('Start')}</a></li>
  <li><a href="${url(controller='profile', action='feed')}">${_("News wall")}</a></li>
  <li class="current"><a href="${url(controller='messages', action='index')}">${_("Inbox")}<span class="edge"></span></a></li>
</ul>

${next.body()}

