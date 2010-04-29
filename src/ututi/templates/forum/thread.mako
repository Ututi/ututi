<%inherit file="/forum/index.mako" />

<a class="back-link" href="${url.current(action='index')}">${_('Back to the topic list')}</a>
<h1>${c.thread.title}</h1>

<table id="forum-thread">
% for forum_post in c.forum_posts:
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
      <span class="small">${h.fmt_dt(forum_post.created_on)}</span>
    </div>
    <div class="forum_post-content">
      <div class="post-body">
        ${h.nl2br(forum_post.message)|n}
      </div>
      <a class="btn" href="#reply"><span>${_('Reply')}</span></a>
    </div>
  </td>
</tr>
% endfor
</table>
<br />
<a name="reply"/>
<h2>${_('Reply')}</h2>
<form method="post" action="${url.current(action='reply')}"
     id="group_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="message">${_('Message')}</label>
    <textarea class="line" name="message" id="message" cols="80" rows="10" style="width: 620px;"></textarea>
  </div>
  ${h.input_submit(_('Reply'))}
</form>
</table>
