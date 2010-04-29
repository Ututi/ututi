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
  <h1 style="float: left;">${c.group.title}</h1>
   % if h.check_crowds(['admin', 'moderator']):
     <div style="float: left; margin-top: 8px; margin-left: 10px;">
       <a class="btn" href="${url.current(action='new_category')}"><span>${_("New category")}</span></a>
     </div>
   % endif
</div>

<br class="clear-left"/>

%if not c.group.forums:
  <span class="small">${_('No forums yet.')}</span>
%endif
<table>
% for forum in c.group.forums:
  <tr>
    <td>
      <a href="${url(controller='forum', action='index', id=c.group.group_id, forum_id=forum.id)}">
        ${forum.title}
      </a>
    </td>
    <td>
      <a class="btn" href="${url.current(forum_id=forum.id, action='new_thread')}"><span>${_("New topic")}</span></a>
    </td>
  </tr>
  <tr>
    <td>
      ${forum.description}
    </td>
  </tr>
  <tr>
    <td>
      ... TODO messages ...
    </td>
  </tr>
% endfor
</table>
