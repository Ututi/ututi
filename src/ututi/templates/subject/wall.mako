<%inherit file="/subject/home.mako" />
<%namespace name="dashboard" file="/sections/wall_dashboard.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${dashboard.head_tags()}
</%def>

<%def name="body_class()">wall</%def>

${dashboard.dashboard(c.msg_recipient, c.file_recipients, c.wiki_recipients)}
${wall.wall_entries(c.events)}
