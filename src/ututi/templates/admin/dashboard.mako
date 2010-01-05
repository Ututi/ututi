<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Adminstration dashboard')}</h1>

<ul>
  <li>${h.link_to('Users', url(controller='admin', action='users'))}</li>
  <li>${h.link_to('Groups', url(controller='admin', action='groups'))}</li>
  <li>${h.link_to('Events', url(controller='admin', action='events'))}</li>
  <li>${h.link_to('Subjects', url(controller='admin', action='subjects'))}</li>
  <li>${h.link_to('Files', url(controller='admin', action='files'))}</li>
  <li>${h.link_to('Import', url(controller='admin', action='import_csv'))}</li>
</ul>
