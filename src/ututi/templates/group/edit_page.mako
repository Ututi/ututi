<%inherit file="/group/home.mako" />

<h1>${_('Edit group front page')}</h1>

<form method="post" action="${url(controller='group', action='update_page', id=c.group.group_id)}"
     id="group_page_edit_form" enctype="multipart/form-data">
  ${h.input_wysiwyg('page_content', _('Content'))}
  ${h.input_submit()}
</form>
