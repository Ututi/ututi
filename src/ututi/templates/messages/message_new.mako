<%inherit file="/messages/base.mako" />

<%def name="title()">
${_('New message')}
</%def>

<form method="post" action="${url(controller='messages', action='new_message')}"
    id="new_message_form" class="fullForm" enctype="multipart/form-data">
  
  %if hasattr(c, 'recipient'):
    ${h.input_line('user', _('User'), '%s' % c.recipient.fullname)}
    ${h.input_hidden('uid', '%s' % c.recipient.id)}
  %else:
    ${h.input_line('user', _('User'))}
    ${h.input_hidden('uid')}
  %endif

  ${h.input_line('title', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  <br />
  ${h.input_submit(_('Post'))}
</form>

<script>
    $('#user').autocomplete({
        source: '${url(controller="messages", action="find_user")}',
        minLength: 2,
        select: function(event, ui) {
            if (ui.item) {
                $('#uid').val(ui.item.id);
            }
        }
    });
</script>
