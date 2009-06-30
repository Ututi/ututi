<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="portlets()">
<div id="sidebar">
  <%self:portlet id="group_portlet">
    <%def name="header()">
      ${_('Groups')}
    </%def>
    <ul>
      % for membership in c.user.memberships:
      <li>
        <a href="${h.url_for(controller='group', action='group_home', id=membership.group.id)}">${membership.group.title}</a>
      </li>
      % endfor
      % if not c.user.memberships:
      ${_('You are not a member of any.')}
      %endif
    </ul>
  </%self:portlet>
</div>
</%def>

<h1>Welcome ${c.user.fullname}!</h1>

<a href="/logout">Log out</a>
