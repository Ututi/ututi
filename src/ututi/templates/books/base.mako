<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="portlets()">
  ${ututi_prizes_portlet()}
  ${user_support_portlet()}
</%def>

${next.body()}

