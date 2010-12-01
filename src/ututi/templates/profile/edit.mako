<%inherit file="/profile/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="tabs" />

<%def name="title()">
  ${c.user.fullname}
</%def>

<%def name="pagetitle()">
${_('Settings')}
</%def>

<a class="back-link" href="${url(controller='profile', action='home')}">${_('back to home page')}</a>

${tabs()}

${next.body()}
