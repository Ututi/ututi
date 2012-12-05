<%inherit file="/location/edit_base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" />

<div>
  <div>
    <%b:light_table title="${_('Sub-departments')}" items="${c.location.sub_departments}">
      <%def name="header(items)">
        <th>${_('Sub-department')}</th>
        <th>${_('The actions')}</th>
      </%def>
      <%def name="row(item)">
        <td>
          <a href="${c.location.url(action='edit_sub_department', id=item.id)}">${item.title}</a>
        </td>
        <td class="actions">
          ${h.button_to(_('Delete'), c.location.url(action='delete_sub_department', id=item.id))}
        </td>
      </%def>
    </%b:light_table>

    <div>
      ${h.button_to(_('Add new sub-department'), c.location.url(action='add_sub_department'))}
    </div>
  </div>
</div>
