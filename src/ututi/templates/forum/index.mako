<%inherit file="/base.mako" />
<%namespace file="/portlets/forum.mako" import="*"/>

<%def name="title()">
  ${c.forum_title}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${forum_info_portlet()}
%if c.forum_id == 'community':
  ${bugs_forum_posts_portlet()}
%elif c.forum_id == 'bugs':
  ${community_forum_posts_portlet()}
%endif
</div>
</%def>

<div id="page_header">
  <h1 style="float: left;">${c.forum_title}</h1>
  <div style="float: left; margin-top: 8px; margin-left: 10px;">
    <a class="btn" href="${url(controller='forum', action='new_thread', forum_id=c.forum_id)}"><span>${_("New topic")}</span></a>
  </div>
</div>
<br class="clear-left"/>


%if not c.forum_posts:
  <span class="small">${_('No messages yet.')}</span>
%endif
<table id="forum-thread-list">
% for forum_post in c.forum_posts:
<tr>
  <td class="subject">
    <a class="thread-subject" href="${url(controller='forum', action='thread', forum_id=c.forum_id, thread_id=forum_post['thread_id'])}">
      ${forum_post['title']}
    </a>
  </td>
  <td class="count">
    ${ungettext("%(count)s reply", "%(count)s replies", forum_post['reply_count']) % dict(count = forum_post['reply_count'])}
  </td>
  <td class="date">
    ${h.fmt_dt(forum_post['created'])}
  </td>
  <td class="author">
    <a href="${forum_post['author'].url()}">${forum_post['author'].fullname}</a>
  </td>
</tr>
% endfor
</table>
