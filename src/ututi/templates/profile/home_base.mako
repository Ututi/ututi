<%inherit file="/ubase-two-sidebars.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/elements.mako" import="tabs" />
<%namespace file="/portlets/sections.mako" import="user_sidebar, user_right_sidebar"/>
<%namespace file="/widgets/facebook.mako" import="init_facebook" />

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="portlets_right()">
${user_right_sidebar()}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
<%newlocationtag:head_tags />
</%def>

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title underline">${self.pagetitle()}</h1>
%endif

${next.body()}
