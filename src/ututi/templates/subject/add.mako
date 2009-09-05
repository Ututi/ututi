<%inherit file="/base.mako" />

<%namespace file="/widgets/locationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
</%def>
<a class="back-link" href="${url(controller='profile', action='search')}">${_('back to the search')}</a>
<h1>${_('New subject')}</h1>

<form method="post" action="${url(controller='subject', action='create')}"
     id="subject_add_form" enctype="multipart/form-data">
  <div class="form-field">
    <label for="id">${_('Id')}</label>
    <div class="input-rounded"><div>
        <input type="text" id="id" name="id" class="line"/>
    </div></div>
  </div>

  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <div class="input-rounded"><div>
        <input type="text" id="title" name="title" class="line"/>
    </div></div>
  </div>
  <div class="form-field">
    <label for="lecturer">${_('Lecturer')}</label>
    <div class="input-rounded"><div>
        <input type="text" id="lecturer" name="lecturer" class="line"/>
    </div></div>
  </div>
  <div class="form-field">
    ${location_widget(3)}
  </div>
  <br class="clear-left"/>
  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget()}
  </div>

  <div class="form-field">
    <label for="description">${_('Brief description of the subject')}</label>
    <textarea class="line" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
