<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Groups')}</h1>

%if c.groups:
    <ol id="group_list">
    %for group in c.groups:
         <li>
                <a href="${h.url_for(controller='group', action='group_home', id=group.id)}" class="group-link">${group.title}</a>
         </li>
    %endfor
    </ul>
%endif
