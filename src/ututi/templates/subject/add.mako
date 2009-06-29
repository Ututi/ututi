<%inherit file="/base.mako" />

<%def name="title()">
${_('New subject')}
</%def>

<h1>${_('New subject')}</h1>

<form method="post" action="${h.url_for(controller='subject', action='new_subject')}"
     id="subject_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <input type="text" id="title" name="title" class="line"/>
  </div>
  <div class="form-field">
    <label for="text_id">${_('Pretty URL')}</label>
    /subject/<input type="text" id="text_id" name="text_id" class="line"/>
  </div>
  <div class="form-field">
    <label for="lecturer">${_('Lecturer')}</label>
    <input type="text" id="lecturer" name="lecturer" class="line"/>
  </div>
  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
