<%inherit file="/base.mako" />

<%def name="title()">
  ${c.user_info.fullname}
</%def>

<h1>${c.user_info.fullname}</h1>
% if c.user_info.logo is not None:
  <img src="${url(controller='profile', action='logo', id=c.user_info.id, width=75, height=100)}" />
% endif
