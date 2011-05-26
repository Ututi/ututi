<%inherit file="/base.mako" />
<%namespace file="/profile/home_base.mako" name="profile" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="portlets_secondary()">
  ${profile.portlets_secondary()}
</%def>

<%def name="pagetitle()">
${_('Private messages')}
</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

${next.body()}

