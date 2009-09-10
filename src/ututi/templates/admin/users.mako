<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Ututi users:')}</h1>
<ol id="user_list">
%for user in c.users:
    <li><a href="${user.url()}">${user.fullname}</a>
    % if user.logo is not None:
       <img src="${url(controller='user', action='logo', id=user.id, width=45, height=60)}" />
    % endif
    </li>
%endfor
</ol>
