<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>



<h1>${_('Notification')}</h1>
<h2>${_('Editing')}</h2>
<form method="post" action="${url(controller='admin', action='update_notification')}"
      name="notification_form" id="notification_form" class="fullForm">
  <input type="hidden" name="id" value=""/>
  ${h.input_line('valid_until', _('Valid until'))}
  ${h.input_area('content', _('Notification text'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>

<script type="text/javascript">
  $(document).ready(function() {
    $('#valid_until').datepicker({ dateFormat: 'mm/dd/yy' });
  });
</script>
