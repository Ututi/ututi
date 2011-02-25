<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="user_sidebar, user_right_sidebar"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="portlets_right()">
${user_right_sidebar()}
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="pageTitle">${self.pagetitle()}</h1>
%endif

${next.body()}
