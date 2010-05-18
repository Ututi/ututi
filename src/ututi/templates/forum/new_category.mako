<%inherit file="/base.mako" />

<%def name="title()">
${_('New category')}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<div id="page_header">
  <h1 style="float: left;">${c.group.title}</h1>
</div>

<br class="clear-left"/>

<a class="back-link" href="${url(controller=c.controller, action='list', id=c.group_id)}">${_('Back to category list')}</a>

<h1>${_('New category')}</h1>

<form method="post" action="${url(controller=c.controller, action='create_category', id=c.group_id)}"
     id="group_add_form" enctype="multipart/form-data">
  ${h.input_line('title', _('Category title'))}
  ${h.input_area('description', _('Description'))}
  ${h.input_submit(_('Create'))}
</form>
