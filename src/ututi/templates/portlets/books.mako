<%inherit file="/portlets/base.mako"/>
<%namespace file="/portlets/user.mako" import="user_support_portlet"/>

<%def name="books_menu()">
  <%self:action_portlet id="button-to-all-books">
    <%def name="header()">
    <a class="blark" href="${url(controller='books', action='index')}">${_('All Books')}</a>
    </%def>
  </%self:action_portlet>
  <%self:action_portlet id="button-to-school-books" expanding="True">
    <%def name="header()">
      ${_('Books for school')}
    </%def>
  </%self:action_portlet>
  <%self:action_portlet id="button-to-students-books" expanding="True">
    <%def name="header()">
      ${_('Books for students')}
    </%def>
  </%self:action_portlet>
  <%self:action_portlet id="button-to-other" expanding="True">
    <%def name="header()">
      ${_('Other')}
    </%def>
  </%self:action_portlet>
  ${user_support_portlet()}
</%def>
