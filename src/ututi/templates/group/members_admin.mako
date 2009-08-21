<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<h1>${_('Members')}</h1>

% for member in c.group.members:
  <div class="user-logo-link">
    % if member.user.logo is not None:
      <img src="${url(controller='user', action='logo', id=member.user.id, width=60, height=60)}" alt="logo" />
    % else:
      ${h.image('/images/user_logo_45x60.png', alt='logo')|n}
    % endif
    <div>
      <a href="${url(controller="user", action="index", id=member.user.id)}" title="${member.user.fullname}">
        ${member.user.fullname}
      </a>
    </div>
  </div>
% endfor
