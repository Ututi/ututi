<%inherit file="/admin/base.mako" />

<%def name="title()">
  Feed
</%def>

<%namespace name="actions" file="/profile/wall_actionblock.mako" import="action_block, head_tags, css"/>
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="css()">
  ${actions.css()}
  .wall a#settings-link {
      margin-top: -5px;
      display: block;
      font-size: 11px;
      text-align: right;
  }

</%def>

<h1>Admin wall</h1>

<div class="wall">
${wall.wall_entries(c.events)}
</div>
