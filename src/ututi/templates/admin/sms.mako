<%inherit file="/admin/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('SMS messages')}</h1>

%if c.messages:
<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s message", "found %(count)s messages", c.messages.item_count) % dict(count = c.messages.item_count)})</span>
  </h3>

  <table id="message_list" style="width: 100%;">
    <tr>
      <th>${_('Sender')}</th>
      <th>${_('Recipient')}</th>
      <th style="width: 30%;">${_('Message')}</th>
      <th>${_('Created')}</th>
      <th>${_('Status')}</th>
    </tr>

    <%
       status_messages = {
         None: _('Not yet sent'),
         0: _('sent'),
         1: _('login problem'),
         2: _('smsc problem'),
         3: _('country not allowed'),
         4: _('params problem'),
         6: _('operator not allowed'),
         7: _('ip not allowed')}
       %>
    %for msg in c.messages:
    <tr>
      <td><a href="${msg.sender.url()}" class="author-link">${msg.sender.fullname}</a></td>
      <td>
        %if msg.recipient:
          <a href="${msg.recipient.url()}" class="author-link">${msg.recipient.fullname}</a>
        %endif
        ${msg.recipient_number}
      </td>
      <td>${msg.message_text}</td>
      <td>${h.fmt_dt(msg.created)}</td>
      <td>
        %if msg.status is None:
          ${status_messages[msg.status]}
        %endif
      </td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.messages.pager(format='~3~') }</div>
</div>
%endif

<h2>${_('Send')}</h2>
<form method="post" action="${url(controller='admin', action='send_sms')}"
      name="sms_form" id="sms_form" enctype="multipart/form-data" class="fullForm">
  ${h.input_line('number', _('Number'))}
  ${h.input_area('message', _('Message'), cols="25", rows="5")}
  <br />
  ${h.input_submit(_('Send'))}
</form>
