<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/elements.mako" import="tabs" />

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="title()">
${c.user.fullname}
</%def>

<%def name="css()">
${parent.css()}
#back-to-home-page {
  display: block;
  margin-bottom: 10px;
}
</%def>

## subheader is actually a placeholder to put in
## a notification block for unverified teachers.
<%def name="subheader()">
  <div class="above-tabs">
    <a class="back-link" href="${url(controller='profile', action='home')}">${_('back')}</a>
  </div>
</%def>

%if hasattr(self, 'pagetitle'):
<h1 class="page-title">${self.pagetitle()}</h1>
%endif

${self.subheader()}

${tabs()}

${next.body()}
