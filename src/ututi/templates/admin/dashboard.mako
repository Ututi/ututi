<%inherit file="/admin/base.mako" />

<%def name="back_link()">
## Don't show back link to dashboard
</%def>

<%def name="css()">
  ${parent.css()}
  #admin-dashboard {
    background: url('img/admin_ukulele.png') no-repeat bottom right;
    padding-right: 50px;
  }
  #admin-dashboard h2 {
    margin: 20px 0;
  }
  #admin-dashboard ul {
    list-style: none;
    font-size: 20px;
  }
  #admin-dashboard ul li {
    float: left;
    padding-right: 50px;
  }
</%def>

<h1>${_('Adminstration dashboard')}</h1>

<div id="admin-dashboard">

<h2>${_('Ututi controls:')}</h2>
<ul class="clearfix">
  <li>${h.link_to('Events', url(controller='admin', action='events'))}</li>
  <li>${h.link_to('Subjects', url(controller='admin', action='subjects'))}</li>
  <li>${h.link_to('Teachers', url(controller='admin', action='teachers'))}</li>
  <li>${h.link_to('Users', url(controller='admin', action='users'))}</li>
  <li>${h.link_to('Files', url(controller='admin', action='files'))}</li>
  <li>${h.link_to('Deleted Files', url(controller='admin', action='deleted_files'))}</li>
  <li>${h.link_to('Groups', url(controller='admin', action='groups'))}</li>
  <li>${h.link_to('Group coupons', url(controller='admin', action='group_coupons'))}</li>
  <li>${h.link_to('I18n texts', url(controller='admin', action='i18n_texts'))}</li>
  <li>${h.link_to('Languages', url(controller='admin', action='languages'))}</li>
  <li>${h.link_to('Messages', url(controller='admin', action='messages'))}</li>
  <li>${h.link_to('Notifications', url(controller='admin', action='notifications'))}</li>
  <li>${h.link_to('SMSs', url(controller='admin', action='sms'))}</li>
</ul>

<h2>${_('uBooks controls:')}</h2>
<ul class="clearfix">
  <li>${h.link_to('Book science types', url(controller='admin', action='science_types'))}</li>
  <li>${h.link_to('Book types', url(controller='admin', action='book_types'))}</li>
  <li>${h.link_to('Cities', url(controller='admin', action='cities'))}</li>
  <li>${h.link_to('School grades', url(controller='admin', action='school_grades'))}</li>
</ul>

<h2>${_('University administration:')}</h2>
<ul class="clearfix">
  <li>${h.link_to('Email domains', url(controller='admin', action='email_domains'))}</li>
</ul>

<h2>${_('Standard UI patterns/objects:')}</h2>
<ul class="clearfix">
  <li>${h.link_to('Blocks', url(controller='admin', action='example_blocks'))}</li>
  <li>${h.link_to('Layouts', url(controller='admin', action='example_layouts'))}</li>
  <li>${h.link_to('Lists', url(controller='admin', action='example_lists'))}</li>
  <li>${h.link_to('Objects', url(controller='admin', action='example_objects'))}</li>
  <li>${h.link_to('Widgets', url(controller='admin', action='example_widgets'))}</li>
</ul>

</div>
