<%inherit file="/subject/home_base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />
<%namespace name="actions" file="/subject/wall_actionblock.mako" import="action_block, head_tags"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="body_class()">wall subject-wall</%def>
%if c.user:
${actions.action_block(c.subject)}
%endif
${wall.wall_entries(c.events)}
