<%inherit file="/ubase.mako" />
<%namespace name="b" file="standard_blocks.mako" />

<%b:rounded_block>
  <div class="block-content">
    This is just a simple block. <br />
    What could be more simple? <br />
    Well, there are many things that are more simple,
    <code>border-radius</code> is one example.
  </div>
</%b:rounded_block>

<%b:rounded_block class_="standard-portlet with-shade icon-subject-orange">
  <h2>Some title</h2>
  <p><strong>It's pretty simple to have these kinds of blocks as well.</strong></p>
  <p>
  Lorem ipsum dolor sit amet, consectetur adipisicing elit, 
  sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
  nisi ut aliquip ex ea commodo consequat.
  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
  dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
  sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
  <p>Some goodies follow:</p>
  <ul class="pros-list">
    <li>Smoking cigarettes</li>
    <li>Watching Captain Kangaroo</li>
    <li>List of possible icon options is in <tt>fixed.css</tt></li>
  </ul>
  ${h.button_to("Click me!", class_='btnMedium')}
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
  <%def name="footer()">
    Some controls, buttons, etc, if needed.
  </%def>
</%b:item_list>

<%b:item_list title='Verry simple list of items' items="${range(3)}">
  <%def name="row(item)">
    Item ${item}
  </%def>
</%b:item_list>
