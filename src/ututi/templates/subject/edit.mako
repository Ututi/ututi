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

<h1>${_('Edit subject')}</h1>

<form method="post" action="${url(controller='subject', action='update', id=c.subject.id, tags=c.subject.location_path)}"
     id="subject_add_form" enctype="multipart/form-data">
  <input type="hidden" name="id" value="${c.subject.id}"/>
  <input type="hidden" name="old_location" value="${c.subject.location_path}"/>
  <div class="form-field">
    <label for="title">${_('Title')}</label>
    <input type="text" id="title" name="title" class="line" value="${c.subject.title}"/>
  </div>
  <div class="form-field">
    <label for="lecturer">${_('Lecturer')}</label>
    <input type="text" id="lecturer" name="lecturer" class="line" value="${c.subject.lecturer}"/>
  </div>
  <div class="form-field">
    <label for="location-0">${_('School')}</label>
    ${location_widget(3, c.subject.location.hierarchy())}
  </div>
  <div class="form-field">
    <label for="tags">${_('Tags')}</label>
    ${tags_widget(c.subject.tags_list)}
  </div>

  <div>
    <span class="btn">
      <input type="submit" value="${_('Save')}"/>
    </span>
  </div>
</form>
