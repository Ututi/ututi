<%inherit file="/about/base.mako" />

<%def name="pagetitle()">${_('Contact Us')}</%def>

<%def name="css()">
  ${parent.css()}

  .contact-text {
     margin-bottom: 20px;
     font-size: 13px;
  }

  #contact-form button {
     margin-top: 15px;
  }

  .left-right {
    margin-top: 20px;
  }
</%def>

<div class="left-right">
  <div class="left">
    <div class="contact-text">${_('Contact us using this form')}:</div>
    <form id="contact-form" method="POST" action="${url(controller='home', action='contacts')}">
      ${h.input_line('name', _('Name:'))}
      ${h.input_line('email', _('Email adress:'))}
      ${h.input_area('message', _('Message:'))}
      ${h.input_submit(_('Send'), class_='dark')}
    </form>
  </div>
</div>
