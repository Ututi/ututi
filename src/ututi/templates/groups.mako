<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Groups')}</h1>

%if c.groups:
    <ol id="group_list">
    %for group in c.groups:
         <li>
                <a href="${url(controller='group', action='home', id=group.group_id)}" class="group-link">${group.title}</a>
         % if group.logo is not None:
                <img src="${url(controller='group', action='logo', id=group.group_id)}" />
         % endif
         </li>
    %endfor
    </ul>
%endif
