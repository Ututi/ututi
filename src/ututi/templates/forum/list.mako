<%inherit file="/base.mako" />
<%namespace file="/portlets/forum.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<div id="page_header">
  <h1 style="float: left;">${_('Forum')}</h1>
   % if h.check_crowds(['admin', 'moderator']):
     <div style="float: left; margin-top: 8px; margin-left: 10px;">
       <a class="btn" href="${url.current(action='new_category')}"><span>${_("New category")}</span></a>
     </div>
   % endif
</div>

<br class="clear-left"/>

%if not c.group.forum_categories:
    <span id="no-categories" class="small">${_('No categories yet.')}</span>
%endif
<table id='forum-categories'>
% for category in c.group.forum_categories:
  <tr>
    <td>
      <a href="${url(controller='forum', action='index', id=c.group.group_id, category_id=category.id)}">
        ${category.title}
      </a>
    </td>
    <td>
      <a class="btn" href="${url.current(category_id=category.id, action='new_thread')}"><span>${_("New topic")}</span></a>
    </td>
  </tr>
  <tr>
    <td>
      ${category.description}
    </td>
  </tr>
  <tr>
    <td>
      ... TODO messages ...
    </td>
  </tr>
% endfor
</table>
