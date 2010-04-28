<%inherit file="/base.mako" />
<%namespace file="/portlets/forum.mako" import="*"/>

<%def name="title()">
  ${c.forum.title}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<div id="page_header">
  <h1 style="float: left;">${c.group.title}</h1>
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
  <td class="count">
    123 TODO
  </td>
  <td class="date">
    2010-10-10 TODO
  </td>
  <td class="author">
    foobar TODO
  </td>
</tr>
% endfor
</table>
