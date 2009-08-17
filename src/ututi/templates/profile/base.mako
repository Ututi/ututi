<%inherit file="/base.mako" />

<%def name="portlets()">
<div id="sidebar">
  <%self:portlet id="search_portlet">
    <%def name="header()">
      ${_('Search')}
    </%def>
    There are searches here!
  </%self:portlet>

  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Watched subjects')}
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
    </ul>
    ${h.button_to(_('Watch subjects'), h.url_for(action='subjects'))} ${h.link_to(_('More subjects'), url(controller='search', action='index', obj_type='subject'))}
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
    ${h.button_to(_('Create group'), h.url_for(controller='group', action='add'))} ${h.link_to(_('More groups'), url(controller='search', action='index', obj_type='group'))}
  </%self:portlet>

</div>
</%def>
