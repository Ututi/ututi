<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<%def name="portlets()">
</%def>

<h1>${_('New blog snippet:')}</h1>

<form method="post"
      action="${url(controller='blog', action='create')}"
      id="new_snippet_form" enctype="multipart/form-data">
      <div class="form-field">
        <label for="title">${_('Title')}</label>
        <input type="text" id="title" name="title"/>
      </div>
      <div class="form-field">
        <label for="url">${_('URL')}</label>
        <input type="text" id="url" name="url"/>
      </div>
      <div class="form-field">
        <label for="date">${_('Date')}</label>
        <input type="text" id="date" name="date"/>
      </div>
      <div class="form-field">
        <label for="content">${_('Content')}</label>
        <textarea name="content" id="snippet-content" cols="60" rows="6"></textarea>
      </div>
      <div class="form-field">
        <input type="submit" value="${_('Save')}"/>
      </div>
</form>
