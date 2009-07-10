<%inherit file="/base.mako" />

<%def name="title()">
${_('Edit page')}
</%def>

<h1>${_('Edit page')}</h1>

<form method="post" action="${h.url_for(controller='page', action='update_page', id=c.page.id)}"
     id="page_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="page_content">${_('Content')}</label>
    <textarea class="line" name="page_content" id="page_content" cols="80" rows="15">${c.page.content}</textarea>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
