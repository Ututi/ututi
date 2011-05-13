<%inherit file="/base.mako" />
<%namespace name="b" file="standard_blocks.mako" />

<%b:title_box title="Title box" style="width: 200px">
  Lorem ipsum dolor sit amet, consectetur adipisicing elit,
  sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
  nisi ut aliquip ex ea commodo consequat.
  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
  dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
  sunt in culpa qui officia deserunt mollit anim id est laborum.
</%b:title_box>

<br />

<%b:title_box title="Wide box">
  By default the width of the box is not fixed.
</%b:title_box>

<div class="feature-box icon-group">
  <div class="title">Feature box:</div>
  <div class="clearfix">
    <div class="feature icon-discussions">
      <strong>Feature one</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
    <div class="feature icon-email">
      <strong>Feature two</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
  </div>
  <div class="clearfix">
    <div class="feature icon-file">
      <strong>Feature three</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
    <div class="feature icon-notifications">
      <strong>Feature four</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
  </div>
  <div class="action-button">
    ${h.button_to('Action button!', url('/'))}
  </div>
</div>

<div class="feature-box icon-subject">
  <div class="title">Feature box can have different icons!</div>
</div>

<div class="feature-box icon-group one-column">
  <div class="title">One column variation:</div>
  <div class="clearfix">
    <div class="feature icon-discussions">
      <strong>Feature one</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
    <div class="feature icon-email">
      <strong>Feature two</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
  </div>
</div>

<div class="feature-box simple">
  <div class="title">Simple feature box showcasing icons:</div>
  <% icons = ['icon-file-orange', 'icon-file', 'icon-file-upload',
    'icon-private-file', 'icon-subjects-file', 'icon-notifications',
    'icon-group', 'icon-email', 'icon-discussions', 'icon-message',
    'icon-chat', 'icon-publications', 'icon-note', 'icon-edit-note',
    'icon-class-note', 'icon-talk', 'icon-wiki', 'icon-administration',
    'icon-branding', 'icon-cv', 'icon-subject', ] %>
  <div class="clearfix">
  %for n, icon in enumerate(icons):
    <div class="feature ${icon}">
      <strong>${icon}</strong>
      Luctus nunc massa a velit. Fusce ac nisi. Integer volutpat elementum metus.
      Vivamus luctus ultricies diam. Curabitur euismod. Vivamus quam. Nunc.
    </div>
  %endfor
  </div>
</div>

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
