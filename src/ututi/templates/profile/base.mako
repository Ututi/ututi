<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="user_sidebar"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="pageTitle">${self.pagetitle()}</h1>
%endif

${next.body()}
