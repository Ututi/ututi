<%inherit file="/location/base_department.mako" />
<%namespace name="subjects" file="/location/subjects.mako" import="*"/>

<%def name="css()">
  ${parent.css()}
  ${subjects.css()}
</%def>

${subjects.search_content()}
