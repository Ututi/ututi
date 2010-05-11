<%inherit file="/base.mako" />
<%namespace file="/portlets/forum.mako" import="*"/>

<%def name="title()">
  ${c.category.title}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${forum_info_portlet()}
  % if c.category.id == 1:
    ${community_forum_posts_portlet()}
  % elif c.category.id == 2:
    ${bugs_forum_posts_portlet()}
  % endif
</div>
</%def>

% if c.group_id is not None:
    <a class="back-link" href="${url(controller=c.controller, action='categories', id=c.group_id)}">${_('Back to category list')}</a>
% endif

<div id="page_header">
  <h1 style="float: left;">${c.category.title}</h1>
  <div style="float: left; margin-top: 8px; margin-left: 10px;">
      <a class="btn" href="${url(controller=c.controller, action='new_thread', id=c.group_id, category_id=c.category.id)}"><span>${_("New topic")}</span></a>
  </div>
</div>

<br class="clear-left"/>

<%def name="forum_thread_list(category, n)">
  <table id="forum-thread-list">
   % for forum_post in category.top_level_messages()[:n]:
  <tr>
    <td class="subject">
        % if forum_post['post'].first_unseen_thread_post(c.user):
          <a href="${url(controller=c.controller, action='thread', id=c.group_id, category_id=category.id, thread_id=forum_post['thread_id'])}#unseen">
            [N]
          </a>
        % endif
        <a class="thread-subject${' unread' if forum_post['post'].first_unseen_thread_post(c.user) else ''}"
        href="${url(controller=c.controller, action='thread', id=c.group_id, category_id=category.id, thread_id=forum_post['thread_id'])}"
        >${forum_post['title']}</a>
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

  <div>
    ${h.button_to(_('Mark all as read'), url(controller=c.controller, action='mark_category_as_read', id=c.group_id, category_id=category.id))}
  </div>
</%def>

${forum_thread_list(c.category, n=10**10)}
<!-- TODO: pagination -->
