<%inherit file="/base.mako" />

<%def name="title()">
${_('New subject')}
</%def>

<h1>${_('New subject')}</h1>

<form method="post" action="${url(controller='subject', action='create')}"
     id="subject_add_form" enctype="multipart/form-data">

  <div class="form-field">
    <label for="location">${_('Location')}</label>
    <input type="text" id="location-1" name="location-1" class="line"/>
    <input type="text" id="location-2" name="location-2" class="line"/>
    <input type="text" id="location-3" name="location-3" class="line"/>
  </div>

  <div class="form-field">
    <label for="id">${_('Id')}</label>
    <input type="text" id="id" name="id" class="line"/>
  </div>

  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <input type="text" id="title" name="title" class="line"/>
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
