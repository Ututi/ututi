<%inherit file="/location/base_department.mako" />
<%namespace file="/location/university.mako" import="*"/>
<%namespace name="groups" file="/location/groups.mako" import="*"/>

<%def name="css()">
  ${parent.css()}
  ${groups.css()}
</%def>

${groups.search_content()}
