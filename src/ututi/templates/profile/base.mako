<%inherit file="/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/search.mako" import="*"/>

<%def name="portlets()">
<div id="sidebar">
  ${search_portlet(parts=['text'], target=url(controller='profile', action='search'))}

  ${user_subjects_portlet()}
  ${user_groups_portlet()}

</div>
</%def>
