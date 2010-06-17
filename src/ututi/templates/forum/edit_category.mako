<%inherit file="/forum/base.mako" />

<a class="back-link" href="${url(controller=c.controller, action='categories', id=c.group_id, category_id=c.category.id)}">${_('Back to category list')}</a>
<h1>${c.category.title}</h1>

<h2>${_('Edit category')}</h2>

% if not c.category.posts:
  <div style="float: right;">
    ${h.button_to(_('Delete category'),
      url(controller=c.controller, action='delete_category',
          id=c.group_id, category_id=c.category.id))}
  </div>
% endif

<form method="post" action="${url(controller=c.controller, action='edit_category', id=c.group_id, category_id=c.category.id)}"
     id="group_add_form" enctype="multipart/form-data" class="fullForm">
  ${h.input_line('title', _('Title'))}
  ${h.input_area('description', _('Description'))}
  <br />
  ${h.input_submit(_('Change'))}
</form>
