<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/elements.mako" import="tabs" />

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="title()">
${c.user.fullname}
</%def>

<%def name="subheader()">
<a class="back-link" href="${url(controller='profile', action='home')}">${_('back to home page')}</a>
</%def>

%if hasattr(self, 'subheader'):
## a placeholder to put in a notification block for unverified teachers
  ${self.subheader()}
%endif

${tabs()}

${next.body()}
