<%inherit file="/location/university.mako" />
<%namespace name="subjects" file="/location/subjects.mako" import="*"/>

<%def name="search_content()">
${subjects.search_content()}
</%def>
