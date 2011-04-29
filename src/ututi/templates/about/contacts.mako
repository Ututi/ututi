<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/portlets/universal.mako" import="contacts_portlet" />

<h1 class="page-title underline">${_('Contact Us')}</h1>

<%def name="portlets_right()">
  ${contacts_portlet()}
</%def>

<%def name="css()">
   ${parent.css()}

   .contact-text {
      margin: 20px 0;
      font-size: 12px;
   }

   #contact-form button {
      margin-top: 15px;
   }
</%def>

%if not message:
<div class="contact-text">${_('Contact us using this form')}:</div>

<form id="contact-form" method="POST" action="${url(controller='home', action='contacts')}">
  ${h.input_line('name', _('Name:'))}
  ${h.input_line('email', _('Email adress:'))}
  ${h.input_area('message', _('Message:'))}
  ${h.input_submit(_('Send'), class_='dark')}
</form>
%else:
<div class="contact-text">${message}</div>
%endif
