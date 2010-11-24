<%inherit file="/ubase-width.mako" />
<%namespace name="b" file="standard_blocks.mako" />

<%b:light_table title="Example light table" items="${range(5)}" class_="light-table">
  <%def name="row(item)">
    <td>
      Some data
    </td>
    <td class="actions">
      ${h.button_to('Action', '#')}
    </td>
  </%def>
</%b:light_table>

<%b:light_table title="Example light table with header and footer" items="${range(5)}" class_="light-table">
  <%def name="header(items)">
    <th>${_('The data')}</th>
    <th>${_('The actions')}</th>
  </%def>
  <%def name="row(item)">
    <td>
      Some data
    </td>
    <td class="actions">
      ${h.button_to('Action', '#')}
    </td>
  </%def>
  <%def name="footer(items)">
    <td colspan="2">
      Total: ${len(items)}
    </td>
  </%def>
</%b:light_table>
