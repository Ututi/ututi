<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="portlets()">
  ${subject_info_portlet()}
  ${ututi_prizes_portlet()}
  ${user_support_portlet()}
</%def>

${next.body()}
