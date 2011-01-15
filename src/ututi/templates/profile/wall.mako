<%inherit file="/profile/base.mako" />
<%namespace name="b" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip" />
<%namespace name="dashboard" file="/sections/wall_dashboard.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="body_class()">wall</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<%def name="head_tags()">
  ${wall.head_tags()}
  ${dashboard.head_tags()}
</%def>

<a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('Wall settings')}</a>

${dashboard.dashboard(None, c.file_recipients, c.wiki_recipients)}

%for event in c.events:
  ${event.wall_entry()}
%endfor
