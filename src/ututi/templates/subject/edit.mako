<%inherit file="/subject/home.mako" />

<%namespace file="/widgets/locationtag.mako" import="*"/>

<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="title()">
${_('Edit subject')}
</%def>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
</%def>
<a class="back-link" href="${url(controller='subject', action='home', id=c.subject.subject_id, tags=c.subject.location_path)}">${_('back to the subject')}</a>
<h1>${_('Edit subject')}</h1>

<form method="post" action="${url(controller='subject', action='update', id=c.subject.subject_id, tags=c.subject.location_path)}"
     id="subject_add_form" enctype="multipart/form-data">
  <input type="hidden" name="id" value="${c.subject.subject_id}"/>
  <input type="hidden" name="old_location" value="${c.subject.location_path}"/>
  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <div class="input-rounded"><div>
        <input type="text" id="title" name="title" class="line" value="${c.subject.title}"/>
    </div></div>
  </div>
  <div class="form-field">
    <label for="lecturer">${_('Lecturer')}</label>
    <div class="input-rounded"><div>
        <input type="text" id="lecturer" name="lecturer" class="line" value="${c.subject.lecturer}"/>
    </div></div>
  </div>
  <div class="form-field">
    ${location_widget(2, c.subject.location.hierarchy())}
  </div>
  <br class="clear-left"/>
  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget(c.subject.tags_list)}
  </div>

  <div class="form-field">
    <label for="description">${_('Brief description of the subject')}</label>
    <textarea class="line" name="description" id="description" cols="60" rows="5">${c.subject.description}</textarea>
  </div>

  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
