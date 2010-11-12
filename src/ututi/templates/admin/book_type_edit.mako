<%inherit file="/ubase.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>



<h1>${_('Book_Type')}: ${c.book_type.name}</h1>
<h2>${_('Editing')}</h2>
<form method="post" action="${url(controller='admin', action='update_book_type', id=c.book_type.id)}"
      name="book_type_form" id="book_type_form" class="fullForm">
  ${h.input_line('name', _('Name'))}
  <br />
  <div>
  ${h.input_submit(_('Edit'))} arba
    ${h.link_to(_("Delete"), url(controller="admin", action="delete_book_type", id=c.book_type.id))}
  </div>
</form>
