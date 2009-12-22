<%inherit file="/base.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${subject_info_portlet(c.subject)}
  ${ututi_prizes_portlet()}
</div>
</%def>
