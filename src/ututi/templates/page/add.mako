<%inherit file="/base.mako" />

<%def name="title()">
${_('New page')}
</%def>

<a class="back-link" href="${c.subject.url()}">${_('Back to %(subject_title)s') % dict(subject_title=c.subject.title)}</a>

<h1>${_('New page')}</h1>

<form method="post" action="${h.url_for(action='create')}"
     id="page_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="page_title">${_('Title')}</label>
    <div class="input-rounded"><div>
        <input class="line" name="page_title" id="page_title" type="text" />
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
