<%inherit file="/portlets/base.mako"/>

<%def name="user_subjects_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Watched subjects')}
    </%def>
    %if not user.watched_subjects:
      ${_('You are not watching any subjects.')}
    %else:
    <ul>
      % for subject in user.watched_subjects:
      <li>
        <a href="${subject.url()}">${subject.title}</a>
      </li>
      % endfor
    </ul>
    %endif
    ${h.button_to(_('Watch subjects'), url(controller='profile', action='subjects', id=user.id))}
    ${h.link_to(_('More subjects'), url(controller='search', action='index', obj_type='subject'), class_="more")}
  </%self:portlet>
</%def>

<%def name="user_groups_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:portlet id="group_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('My groups')}
    </%def>
    % if not user.memberships:
      ${_('You are not a member of any.')}
    %else:
    <ul>
      % for membership in user.memberships:
      <li>
        <a href="${membership.group.url()}">${membership.group.title}</a>
      </li>
      % endfor
    </ul>
    %endif
    ${h.button_to(_('Create group'), url(controller='group', action='add'))}
    ${h.link_to(_('More groups'), url(controller='search', action='index', obj_type='group'), class_="more")}
  </%self:portlet>
</%def>
