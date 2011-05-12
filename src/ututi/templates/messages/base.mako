<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/profile/home_base.mako" name="profile" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="portlets_right()">
  ${profile.portlets_right()}
</%def>

<%def name="pagetitle()">
${_('Private messages')}
</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

${next.body()}

