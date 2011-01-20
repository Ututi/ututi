<%inherit file="/profile/base.mako" />
<%namespace name="b" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip" />
<%namespace name="actions" file="/profile/wall_actionblock.mako" import="action_block, head_tags"/>
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="body_class()">wall</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<%def name="head_tags()">
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('Wall settings')}</a>

${actions.action_block(None, c.file_recipients, c.wiki_recipients)}
${wall.wall_entries(c.events)}
