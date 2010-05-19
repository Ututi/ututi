<%inherit file="/forum/index.mako" />

<a class="back-link" href="${url(controller=c.controller, action='index', id=c.group_id, category_id=c.category_id)}">${_('Back to the topic list')}</a>
<h1>${c.thread.title}</h1>

<div>
  % if not c.subscribed:
    ${h.button_to(_('Subscribe to emails'), url(controller=c.controller, action='subscribe', id=c.group_id, category_id=c.category_id, thread_id=c.thread.id))}
  % else:
    ${h.button_to(_('Unsubscribe from emails'), url(controller=c.controller, action='unsubscribe', id=c.group_id, category_id=c.category_id, thread_id=c.thread.id))}
  % endif
</div>

<table id="forum-thread">
% for forum_post in c.forum_posts:
  % if forum_post != c.forum_posts[0] and c.first_unseen and forum_post.id == c.first_unseen.id:
    <tr>
        <td colspan="2"><a name="unseen"></a><hr /><td>
    </tr>
  % endif
  <tr class="thread-post">
  <td class="author-logo">
    <a href="${forum_post.created.url()}">
      %if forum_post.created.logo is not None:
        <img alt="user-logo" src="${url(controller='user', action='logo', id=forum_post.created.id, width='45', height='60')}"/>
      %else:
        ${h.image('/images/user_logo_45x60.png', alt='logo', id='group-logo')|n}
      %endif
    </a>
  </td>
  <td class="forum_post">
    <div class="forum_post-header">
      <a href="${forum_post.created.url()}">${forum_post.created.fullname}</a>
      % for medal in forum_post.created.all_medals():
          ${medal.img_tag()}
      % endfor
      <span class="small">${h.fmt_dt(forum_post.created_on)}</span>
    </div>
    <div class="forum_post-content">
      <div class="post-body">
        ${h.nl2br(forum_post.message)}
      </div>
      % if c.can_post(c.user):
        <a class="btn" href="#reply"><span>${_('Reply')}</span></a>
      % endif
      % if c.can_manage_post(forum_post):
        ${h.button_to(_('Edit'), url(controller=c.controller, action='edit', id=c.group_id, category_id=c.category_id, thread_id=forum_post.id))}
        ${h.button_to(_('Delete') if forum_post != c.forum_posts[0] else _('Delete thread'), url(controller=c.controller, action='delete_post', id=c.group_id, category_id=c.category_id, thread_id=forum_post.id))}
      % endif
    </div>
  </td>
</tr>
% endfor
</table>

% if c.can_post(c.user):
  <br />
  <a name="reply"/>
  <h2>${_('Reply')}</h2>
  <form method="post" action="${url(controller=c.controller, action='reply', id=c.group_id, category_id=c.category_id, thread_id=c.thread_id)}"
       id="group_add_form" enctype="multipart/form-data">
    <div class="form-field">
      <label for="message">${_('Message')}</label>
      <textarea class="line" name="message" id="message" cols="80" rows="10" style="width: 620px;"></textarea>
    </div>
    ${h.input_submit(_('Reply'))}
  </form>
% endif
