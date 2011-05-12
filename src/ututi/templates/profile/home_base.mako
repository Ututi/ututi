<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/portlets/sections.mako" import="user_sidebar, user_right_sidebar"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="portlets_right()">
${user_right_sidebar()}
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title underline">${self.pagetitle()}</h1>
%endif

${next.body()}
