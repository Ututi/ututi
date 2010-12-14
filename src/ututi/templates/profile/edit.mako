<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="tabs" />

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="title()">
${c.user.fullname}
</%def>

<a class="back-link" href="${url(controller='profile', action='home')}">${_('back to home page')}</a>

${tabs()}

${next.body()}
