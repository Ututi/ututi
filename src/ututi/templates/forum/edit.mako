<%inherit file="/forum/index.mako" />

<a class="back-link" href="${url(controller=c.controller, action='thread', id=c.group_id, category_id=c.category.id, thread_id=c.thread.id)}">${_('Back to thread')}</a>
<h1>${c.thread.title}</h1>

<h2>${_('Edit')}</h2>
<form method="post" action="${url(controller=c.controller, action='edit_post', id=c.group_id, category_id=c.category.id, thread_id=c.thread.id)}"
     id="group_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="message">${_('Message')}</label>
    <textarea class="line" name="message" id="message" cols="80" rows="10" style="width: 620px;"></textarea>
  </div>
  ${h.input_submit(_('Submit'))}
</form>
</table>
