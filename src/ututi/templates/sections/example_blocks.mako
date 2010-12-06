<%inherit file="/ubase-width.mako" />
<%namespace name="b" file="standard_blocks.mako" />

<%b:rounded_block>
  <div class="block-content">
    This is just a simple block. <br />
    What could be more simple? <br />
    Well, there are many things that are more simple,
    <code>border-radius</code> is one example.
  </div>
</%b:rounded_block>

<%b:light_table title="Example light table" items="${range(5)}">
  <%def name="row(item)">
    <td>
      Some data
    </td>
    <td class="actions">
      ${h.button_to('Action', '#')}
    </td>
  </%def>
</%b:light_table>

<%b:light_table title="Example light table with header and footer" items="${range(5)}">
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

<%b:item_list title='List of items' items="${range(5)}">
  <%def name="header_link()">
    <a href="#">this is a link</a>
  </%def>
  <%def name="header_button()">
    ${h.button_to('a button', '#')}
  </%def>
  <%def name="row(item)">
    Item ${item}
  </%def>
  <%def name="last_row(item)">
    Last item ${item}
  </%def>
</%b:item_list>
