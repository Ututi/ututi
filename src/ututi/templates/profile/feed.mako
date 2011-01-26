<%inherit file="/profile/home_base.mako" />
<%namespace name="b" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip" />
<%namespace name="actions" file="/profile/wall_actionblock.mako" import="action_block, head_tags, css"/>
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="body_class()">wall</%def>

<%def name="pagetitle()">
  ${_("News feed")}
</%def>

<%def name="head_tags()">
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="css()">
  ${actions.css()}
  /* Align page title and wall settings link in this page. */
  .wall .pageTitle {
      display: inline;
  }
  .wall a#settings-link {
      margin-top: 10px;
      font-size: 11px;
      float: right;
  }

</%def>

<a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('News feed settings')}</a>
%if not c.user.is_teacher:
  ${self.homepage_nags_and_stuff()}
%endif

${actions.action_block(c.msg_recipients, c.file_recipients, c.wiki_recipients)}
${wall.wall_entries(c.events)}
