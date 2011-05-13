<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<style type="text/css">
tr.active {
  background: #C0FDCD;
}
tr.inactive {
  background: #FDC0C6;
}
</style>

%if c.notifications:
  <table id="notifications_list" style="width: 100%;">
    <tr>
      <th>${_('Content')}</th>
      <th>${_('Valid until')}</th>
    </tr>

    %for notification in c.notifications:
    <tr class="${'active' if notification.active() else 'inactive'}">
      <td>${notification.content|n}</td>
      <td>${notification.valid_until}</td>
      <td>${h.link_to(_('Edit'), url(controller="admin", action="edit_notification", id=notification.id)) }</td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.notifications.pager(format='~3~') }</div>
%endif


<h1>${_('Notifications')}</h1>
<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='add_notification')}"
      name="notification_form" id="notifications_form" class="fullForm">
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

