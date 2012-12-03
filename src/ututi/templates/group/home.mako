<%inherit file="/group/base.mako" />
<%namespace name="actions" file="/group/wall_actionblock.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="body_class()">wall group-wall</%def>

%if getattr(c, 'welcome', None):
  <h1>${_('Congratulations, you have created a new group!')}</h1>

  <%self:rounded_block id="group-welcome-text">
    %if c.group.forum_is_public:
${h.literal(_("""
VUtuti groups are a communication tool for you and your friends. Here
your group can use the <a href="%(link_to_forums)s">forums</a> and store
private files.
""") % dict(link_to_forums=c.group.url(action='forum')))}
    %else:
${h.literal(_("""
VUtuti groups are a communication tool for you and your friends. Here
your group can use the <a href="%(link_to_forums)s">forums</a>, keep
private files and <a href="%(link_to_subjects)s">watch subjects</a>
you are studying.
""") % dict(link_to_forums=c.group.url(action='forum'),
            link_to_subjects=c.group.url(action='subjects')))}
    %endif
  </%self:rounded_block>
%endif

${actions.action_block(c.group)}
${wall.wall_entries(c.events)}
