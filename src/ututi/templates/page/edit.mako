<%inherit file="/page/view.mako" />

<%def name="title()">
${_('Edit page')}
</%def>
<a class="back-link" href="${c.page.url()}">${_('Back to %(page_title)s') % dict(page_title=c.page.title)}</a>
<h1>${_('Edit page')}</h1>

<form method="post" action="${h.url_for(action='update')}"
     id="page_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="page_title">${_('Title')}</label>
    <div class="input-line"><div>
        <input class="line" name="page_title" id="page_title" type="text" value="" />
    </div></div>
  </div>
  <div class="form-field">
    <label for="page_content">${_('Content')}</label>
    <textarea class="ckeditor" name="page_content" id="page_content" cols="80" rows="25"></textarea>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
