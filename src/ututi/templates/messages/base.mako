<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
${user_sidebar()}
</%def>

<%def name="portlets_right()">
${user_right_sidebar()}
</%def>

<%def name="pagetitle()">
${_('Home')}
</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

${next.body()}

