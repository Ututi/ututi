<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Ututi users:')}</h1>
<ul id="user_list">
%for user in c.users:
    <li>${user.fullname}
    % if user.logo is not None:
       <img src="${h.url_for(controller='profile', action='logo', id=user.id, width=45, height=60)}" />
    % endif
    </li>
%endfor
</ul>
