<%doc>
  Wall actionblock snippets, works together with dashboard.js.
</%doc>

<%namespace name="base" file="/prebase.mako" import="rounded_block"/>

<%def name="head_tags()">
  ${h.javascript_link('/javascript/dashboard.js')}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')}
</%def>

<%def name="action_block()">

  <%base:rounded_block id="dashboard_actions">

  <div class="tip">${_('Share with others')}</div>
  ${caller.links()}
  </%base:rounded_block>

  <div id="dashboard_action_blocks">
    ${caller.body()}
  </div>

</%def>
