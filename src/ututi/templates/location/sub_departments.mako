<%inherit file="/location/catalog.mako" />
<%namespace file="/search/index.mako" name="search" import="search_form, search_results"/>

<%def name="sub_department_snippet(sub_department)">
  ${sub_department.snippet()}
</%def>

<%def name="search_results(results, search_query=None)">
  <%search:search_results results="${results}" controller='location' action='catalog_js' display="${self.sub_department_snippet}">
    <%def name="header()">
      ${_('Sub-departments')}
    </%def>
  </%search:search_results>
</%def>

<%def name="search_form()">
## Can't search here
</%def>

<%def name="empty_box()">
## This link is not displayed anywhere if location has no sublocations
</%def>
