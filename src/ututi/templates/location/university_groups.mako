<%inherit file="/location/base_university.mako" />
<%namespace name="groups" file="/location/groups.mako" import="*"/>

<%def name="css()">
  ${parent.css()}
  ${groups.css()}
</%def>

${groups.search_content()}
