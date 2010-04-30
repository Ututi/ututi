<%inherit file="/subject/home.mako" />

<%namespace name="newlocationtag" file="/widgets/newlocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('Edit subject')}
</%def>

<%def name="head_tags()">
<%newlocationtag:head_tags />
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
</%def>

<a class="back-link" href="${url(controller='subject', action='home', id=c.subject.subject_id, tags=c.subject.location_path)}">${_('back to the subject')}</a>
<h1>${_('Edit subject')}</h1>

<form method="post" action="${url(controller='subject', action='update', id=c.subject.subject_id, tags=c.subject.location_path)}"
     id="subject_add_form" enctype="multipart/form-data">
  <input type="hidden" name="id" value=""/>
  <input type="hidden" name="old_location" value=""/>
  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <div class="input-line"><div>
        <input type="text" id="title" name="title" class="line" value=""/>
    </div></div>
  </div>
  <div class="form-field">
    <label for="lecturer">${_('Lecturer')}</label>
    <div class="input-line"><div>
        <input type="text" id="lecturer" name="lecturer" class="line" value=""/>
    </div></div>
  </div>
    ${location_widget(2)}
  <br class="clear-left"/>
  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget()}
  </div>

  <div class="form-field">
    <label for="description">${_('Brief description of the subject')}</label>
    <textarea class="line ckeditor" name="description" id="description" cols="60" rows="5"></textarea>
  </div>

  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
