<%inherit file="/location/department.mako" />
<%namespace file="/location/university.mako" import="*"/>
<%namespace name="groups" file="/location/groups.mako" import="*"/>

<%def name="search_content()">
${groups.search_content()}
</%def>
