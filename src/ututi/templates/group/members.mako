<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<h1>${_('Members')}</h1>

% if c.group.members:
<ul id="group_member_list">
% for member in c.group.members:
  <li>${member.user.fullname}</li>
% endfor
</ul>
%endif
