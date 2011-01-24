<%inherit file="/subject/home.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<%def name="body_class()">wall</%def>

${wall.wall_entries(c.events)}
