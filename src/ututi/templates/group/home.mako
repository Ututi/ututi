<%inherit file="/group/base.mako" />
<%namespace name="actions" file="/group/wall_actionblock.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${actions.head_tags()}
</%def>

<%def name="body_class()">wall</%def>

%if getattr(c, 'welcome', None):
  <h1>${_('Congratulations, you have created a new group!')}</h1>

  <%self:rounded_block id="group-welcome-text">
    %if c.group.forum_is_public:
${h.literal(_("""
Ututi groups are a communication tool for you and your friends. Here
your group can use the <a href="%(link_to_forums)s">forums</a> and store
private files.
""") % dict(link_to_forums=c.group.url(action='forum')))}
    %else:
${h.literal(_("""
Ututi groups are a communication tool for you and your friends. Here
your group can use the <a href="%(link_to_forums)s">forums</a>, keep
private files and <a href="%(link_to_subjects)s">watch subjects</a>
you are studying.
""") % dict(link_to_forums=c.group.url(action='forum'),
            link_to_subjects=c.group.url(action='subjects')))}
    %endif
  </%self:rounded_block>
%endif


%if c.has_to_invite_members:
  <%self:rounded_block id="invite_members_block" class_="portletInviteMembers">
    <div class="floatleft usergrupeleft" style="width: 320px">
      <h2 class="portletTitle bold">${_("Invite group members!")}</h2>
${_("""
It's easy - you just have to know their email addresses! You can
use the group mailing list together then!
""")}
    </div>
    <div class="floatright">
      ${h.button_to(_('Invite friends'), c.group.url(action='members'), class_='btnMedium')}
    </div>
    <br class="clear-left" />
  </%self:rounded_block>

%endif

%if c.wants_to_watch_subjects:
  <%self:rounded_block id="watch_subjects_block" class_="portletNewDalykas">
    <div class="floatleft usergrupeleft">
      <h2 class="portletTitle bold">${_('Watch subjects you are studying!')}</h2>
      <ul id="prosList">
        <li>${_('Find materials shared by others')}</li>
        <li>${_('Get notifications about changes')}</li>
      </ul>
    </div>
    <div class="floatright">
       ${h.button_to(_('Watch subjects'), c.group.url(action='subjects'), class_='btnMedium')}
       <br class="clear-left" />
       <span style="float: left; padding-left: 3.5em;">
         <a href="${c.group.url(action='home', do_not_watch=True)}" class="cancel_link">${_('no, thank you')}</a>
       </span>
    </div>
    <br class="clear-left" />
  </%self:rounded_block>
%endif
${actions.action_block(c.group)}
${wall.wall_entries(c.events)}
