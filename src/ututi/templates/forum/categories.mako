<%inherit file="/base.mako" />
<%namespace file="/portlets/forum.mako" import="*"/>
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/forum/index.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${group_sidebar()}
</div>
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
       <a class="btn" href="${url(controller=c.controller, action='new_category', id=c.group_id)}"><span>${_("New category")}</span></a>
     </div>
   % endif
</div>

<br class="clear-left"/>

%if not c.group.forum_categories:
    <span id="no-categories" class="small">${_('No categories yet.')}</span>
%endif
% for category in c.group.forum_categories:
  <hr />
  <h2 class="category">
      <a href="${url(controller=c.controller, action='index', id=c.group_id, category_id=category.id)}"
          >${category.title}</a>
  </h2>
  <div>${category.description}</div>
  ${forum_thread_list(category, n=5)}
  % if c.can_post(c.user):
    <a class="btn" href="${url(controller=c.controller, action='new_thread', id=c.group_id, category_id=category.id)}"
        ><span>${_("New topic")}</span></a>
  % endif
% endfor
</table>
