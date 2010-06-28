<%inherit file="/admin/base.mako" />

<%def name="title()">
  Messages
</%def>

<form method="post" action="${url(controller='admin', action='messages')}"
      id="new_message_form" class="fullForm" enctype="multipart/form-data">
  ${h.input_line('title', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  <br />
  ${h.input_submit(_('Post'))}
</form>

<script>
    $('#new_message_form').submit(function() {
        var sending_text = '${_('Sending...')}';
        var btn = $('#new_message_form button');
        btn.attr('disabled', 'disabled');
        $('span', btn).text(sending_text)
    });
</script>
