<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  ${h.javascript_link('/javascript/jquery-ui-1.7.2.custom.min.js')}
  ${h.stylesheet_link(h.path_with_hash('/jquery-ui-1.7.3.custom.css'))}
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Group Coupons')}</h1>

<style type="text/css">
tr.active {
  background: #C0FDCD;
}
tr.inactive {
  background: #FDC0C6;
}
</style>
%if c.groupcoupons:
<div id="search-results-container">
  <h3 class="underline search-results-title">
    <span class="result-count">(${ungettext("found %(count)s coupon", "found %(count)s coupons", c.groupcoupons.item_count) % dict(count = c.groupcoupons.item_count)})</span>
  </h3>

  <table id="coupon_list" style="width: 100%;">
    <tr>
      <th>${_('Code')}</th>
      <th>${_('Created')}</th>
      <th>${_('Valid until')}</th>
      <th>${_('Action')}</th>
      <th>${_('Parameter')}</th>
      <th>${_('Groups using')}</th>
    </tr>

    %for coupon in c.groupcoupons:
    <tr class="${'active' if coupon.active() else 'inactive'}">
      <td style="font-size: 1.5em;">${coupon.id}</td>
      <td>${h.fmt_dt(coupon.created)}</td>
      <td>${h.fmt_dt(coupon.valid_until)}</td>
      <td>${coupon.action}</td>
      <td>${coupon.credit_count or coupon.day_count}</td>
      <td style="font-size:1.2em;">${len(coupon.groups)}</td>
    </tr>
    %endfor
  </table>
  <div id="pager">${c.groupcoupons.pager(format='~3~') }</div>
</div>
%endif

<h2>${_('Add')}</h2>
<form method="post" action="${url(controller='admin', action='add_coupon')}"
      name="coupon_form" id="coupon_form" enctype="multipart/form-data" class="fullForm">
  ${h.input_line('code', _('Code'))}
  <label for="action">${_('Action')}</label>
  <select name="action" id="action">
    <option value="">${_('Select')}</option>
    <option value="smscredits">${_('SMS Credits')}</option>
    <option value="unlimitedspace">${_('Unlimited space')}</option>
  </select>
  ${h.input_line('credit_count', _('Credit count (for sms credits)'))}
  ${h.input_line('day_count', _('Day count (for unlimited space)'))}
  ${h.input_line('valid_until', _('Valid until'))}
  <br />
  ${h.input_submit(_('Save'))}
</form>

<script type="text/javascript">
  $(document).ready(function() {
    $('#valid_until').datepicker({ dateFormat: 'mm/dd/yy' });
    $('#action').change(function() {
        act = $(this).val();
        switch(act) {
            case 'smscredits':
              $('#credit_count').val('').closest('label').show();
              $('#day_count').val('').closest('label').hide();
              break;
            case 'unlimitedspace':
              $('#credit_count').val('').closest('label').hide();
              $('#day_count').val('').closest('label').show();
              break;
            default:
              $('#credit_count').val('').closest('label').hide();
              $('#day_count').val('').closest('label').hide();
        }

    });
  });
</script>
