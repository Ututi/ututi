<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${_('Science type')}: ${c.science_type.name}</h1>
<h2>${_('Editing')}</h2>
<form method="post" action="${url(controller='admin', action='update_science_type', id=c.science_type.id)}"
      name="science_type_form" id="science_type_form" class="fullForm">
  ${h.input_line('name', _('Name'))}
  <br />
  <label>${_('Book department')}: ${h.select('department', None, c.book_departments)}</label>
  <br />
  <div>
  ${h.input_submit(_('Edit'))} ${_('or')}
    ${h.link_to(_("Delete"), url(controller="admin", action="delete_science_type", id=c.science_type.id))}
  </div>
</form>

<script type="text/javascript">
  $(document).ready(function() {
    $('#valid_until').datepicker({ dateFormat: 'mm/dd/yy' });
  });
</script>
