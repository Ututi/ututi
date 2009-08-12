<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="portlets()">
<div id="sidebar">
  <%self:portlet id="search_portlet">
    <%def name="header()">
      ${_('Search')}
    </%def>
    There are searches here!
  </%self:portlet>

  <%self:portlet id="group_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('My groups')}
    </%def>
    <ul>
      % for membership in c.user.memberships:
      <li>
        <a href="${membership.group.url()}">${membership.group.title}</a>
      </li>
      % endfor
      % if not c.user.memberships:
      ${_('You are not a member of any.')}
      %endif
    </ul>
  </%self:portlet>

  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('My subjects')}
    </%def>
    <ul>
      % for subject in c.user.watched_subjects:
      <li>
        <a href="${subject.url()}">${subject.title}</a>
      </li>
      % endfor
      % if not c.user.watched_subjects:
      ${_('You are not watching any subjects.')}
      %endif
      <a href="${h.url_for(action='subjects')}">Watch subjects</a>
    </ul>
  </%self:portlet>

</div>
</%def>

<h1>Welcome ${c.user.fullname}!</h1>

<a href="${url('/logout')}">Log out</a>
