<%inherit file="/profile/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="tabs" />

<%def name="title()">
  ${c.user.fullname}
</%def>

<%def name="pagetitle()">
${_('Profile settings')}
</%def>

<a class="back-link" href="${url(controller='profile', action='home')}">${_('back to the profile')}</a>

${tabs()}

${next.body()}
