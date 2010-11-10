<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>



<h1>${_('City')}: ${c.city.name}</h1>
<h2>${_('Editing')}</h2>
<form method="post" action="${url(controller='admin', action='update_city', id=c.city.id)}"
      name="city_form" id="city_form" class="fullForm">
  <input type="hidden" name="id" value=""/>
  ${h.input_line('name', _('Name'))}
  <br />
  <div>
  ${h.input_submit(_('Edit'))} arba
##  <div style="display:inline-block; position:relative; top:8px">
    ${h.link_to(_("Delete"), url(controller="admin", action="delete_city", id=c.city.id))}
##  </div>
  </div>
</form>

<script type="text/javascript">
  $(document).ready(function() {
    $('#valid_until').datepicker({ dateFormat: 'mm/dd/yy' });
  });
</script>
