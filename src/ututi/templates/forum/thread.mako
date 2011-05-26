<%inherit file="/forum/base.mako" />

<%def name="css()">
.portletGroupMailingList {
    background-color: white;
}
</%def>

<div class="back-link">
  <a class="back-link" href="${url(controller=c.controller, action='index', id=c.group_id, category_id=c.category_id)}"
    >${_('Back to the topic list')}</a>
</div>

  <%self:rounded_block class_="portletGroupFiles portletGroupMailingList smallTopMargin">

<div class="single-title">
  <div style="float: right">
    % if not c.subscribed:
      ${h.button_to(_('Subscribe to emails'), url(controller=c.controller, action='subscribe', id=c.group_id, category_id=c.category_id, thread_id=c.thread.id))}
    % else:
      ${h.button_to(_('Unsubscribe from emails'), url(controller=c.controller, action='unsubscribe', id=c.group_id, category_id=c.category_id, thread_id=c.thread.id))}
    % endif
  </div>
  <h2 class="portletTitle bold category-title" style="padding-bottom: 7px">${c.thread.title}</h2>
</div>

<table id="forum-thread">
% for forum_post in c.forum_posts:
  % if forum_post != c.forum_posts[0] and c.first_unseen and forum_post.id == c.first_unseen.id:
    <tr> <td colspan="2"><a name="unseen"></a><hr /><td>
    </tr>
  % endif
  <tr>
    <td colspan="2" class="author">
      <a href="${forum_post.created.url()}">${forum_post.created.fullname}</a>
      <span class="created-on">${h.fmt_dt(forum_post.created_on)}</span>
        % if c.can_manage_post(forum_post):
          <div style="float:right">
            ${h.button_to(_('Edit'), url(controller=c.controller, action='edit', id=c.group_id, category_id=c.category_id, thread_id=forum_post.id))}
          </div>
          <div style="float:right">
            ${h.button_to(_('Delete') if forum_post != c.forum_posts[0] else _('Delete thread'), url(controller=c.controller, action='delete_post', id=c.group_id, category_id=c.category_id, thread_id=forum_post.id))}
          </div>
        % endif
        % if c.can_post(c.user):
          <div style="float: right">
            ${h.button_to(_('Reply'), url(controller=c.controller, action='thread', id=c.group_id, category_id=c.category_id, thread_id=c.thread_id) + '#reply')}
          </div>
        % endif
    </td>
  </tr>
  <tr class="thread-post">
    <td class="author-logo">
      <a href="${forum_post.created.url()}">
        <img alt="user-logo" src="${forum_post.created.url(action='logo', width=45)}"/>
      </a>
    </td>
    <td class="forum_post">
      <div class="forum_post-content">
        <div class="post-body">
          ${h.nl2br(forum_post.message)}
        </div>
      </div>
    </td>
  </tr>
% endfor
</table>
<div id="pager">
  ${c.forum_posts.pager(format='~3~', controller=c.controller, action='thread', thread_id=c.thread.id, id=c.group_id, category_id=c.category.id)}
</div>

% if c.can_post(c.user):
  <div id="reply-section">
    <a name="reply"></a>
    <h2>${_('Reply')}</h2>
    <br />
    <form method="post" action="${url(controller=c.controller, action='reply', id=c.group_id, category_id=c.category_id, thread_id=c.thread_id)}"
         id="forum_reply_form" class="fullForm" enctype="multipart/form-data">
      ${h.input_area('message', _('Message'))}
      <br />
      ${h.input_submit(_('Reply'))}
    </form>
  </div>
% endif

</%self:rounded_block>
