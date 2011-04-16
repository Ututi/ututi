<%inherit file="/profile/home_base.mako" />
<%namespace file="/elements.mako" import="tooltip" />
<%namespace name="actions" file="/profile/wall_actionblock.mako" import="action_block, head_tags, css"/>
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="body_class()">wall profile-wall</%def>

<%def name="pagetitle()">
  ${_("News feed")}
</%def>

<%def name="head_tags()">
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="css()">
  ${actions.css()}
  .wall a#settings-link {
      display: block;
      float: right;
      margin-top: -30px; /* throws above page title (XXX) */
      padding-left: 14px;
      background: url('/img/icons.com/settings.png') no-repeat left center;
  }

</%def>

<a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('News feed settings')}</a>

${actions.action_block(c.msg_recipients, c.file_recipients, c.wiki_recipients)}

${wall.wall_entries(c.events)}
