<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Adminstration dashboard')}</h1>

<h2>${_('Ututi controls:')}</h2>

<ul>
  <li>${h.link_to('Users', url(controller='admin', action='users'))}</li>
  <li>${h.link_to('Groups', url(controller='admin', action='groups'))}</li>
  <li>${h.link_to('Events', url(controller='admin', action='events'))}</li>
  <li>${h.link_to('Subjects', url(controller='admin', action='subjects'))}</li>
  <li>${h.link_to('Files', url(controller='admin', action='files'))}</li>
  <li>${h.link_to('Deleted Files', url(controller='admin', action='deleted_files'))}</li>
  <li>${h.link_to('Messages', url(controller='admin', action='messages'))}</li>
  <li>${h.link_to('SMSs', url(controller='admin', action='sms'))}</li>
  <li>${h.link_to('Group coupons', url(controller='admin', action='group_coupons'))}</li>
  <li>${h.link_to('Notifications', url(controller='admin', action='notifications'))}</li>
  <li>${h.link_to('Cities', url(controller='admin', action='cities'))}</li>
  <li>${h.link_to('School grades', url(controller='admin', action='school_grades'))}</li>
  <li>${h.link_to('Book science types', url(controller='admin', action='science_types'))}</li>
  <li>${h.link_to('Book types', url(controller='admin', action='book_types'))}</li>
  <li>${h.link_to('Teachers', url(controller='admin', action='teachers'))}</li>
  <li>${h.link_to('Languages', url(controller='admin', action='languages'))}</li>
  <li>${h.link_to('I18n texts', url(controller='admin', action='i18n_texts'))}</li>
</ul>

<h2>${_('Standard UI patterns/objects')}</h2>
<ol>
  <li>${h.link_to('Standard blocks', url(controller='admin', action='example_blocks'))}</li>
  <li>${h.link_to('Standard lists', url(controller='admin', action='example_lists'))}</li>
  <li>${h.link_to('Standard objects', url(controller='admin', action='example_objects'))}</li>
  <li>${h.link_to('Standard widgets', url(controller='admin', action='example_widgets'))}</li>
  <li>${h.link_to('Standard layouts', url(controller='admin', action='example_layouts'))}</li>
</ol>
