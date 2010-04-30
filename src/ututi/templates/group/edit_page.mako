<%inherit file="/group/home.mako" />

<h1>${_('Edit group front page')}</h1>

<%def name="head_tags()">
${parent.head_tags()}
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<form method="post" action="${url(controller='group', action='update_page', id=c.group.group_id)}"
     id="group_page_edit_form" enctype="multipart/form-data">
  ${h.input_wysiwyg('page_content', _('Content'))}
  <div class="form-field">
    <label for="page_public">
      <input type="checkbox" name="page_public" id="page_public" value="public"/>
      ${_('Group page is visible to everybody')}
    </label>
  </div>
  ${h.input_submit()}
</form>
