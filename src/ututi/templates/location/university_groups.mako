<%inherit file="/location/university.mako" />
<%namespace name="groups" file="/location/groups.mako" import="*"/>

<%def name="search_content()">
${groups.search_content()}
</%def>
