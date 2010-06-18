<%inherit file="/group/base.mako" />

%if c.welcome:
  <h1>${_('Congratulations, you have created a new group!')}</h1>

  <%self:rounded_block>
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
  <%self:rounded_block id="invite_members_block">
    <div class="floatleft usergrupeleft">
      <h2 class="portletTitle bold">${_("Invite group members!")}</h2>
${_("""
It's easy - you just have to know their email addresses! You can
use the group mailing list together then!
""")}
    </div>
    <div class="floatleft usergruperight">
      ${h.button_to(_('Invite friends'), c.group.url(action='members'), class_='btnMedium')}
    </div>
    <br class="clear-left" />
  </%self:rounded_block>

%endif

%if c.wants_to_watch_subjects:
  <%self:rounded_block id="user_location" class_="portletNewDalykas">
    <div class="floatleft usergrupeleft">
      <h2 class="portletTitle bold">${_('Watch subjects you are studying!')}</h2>
      <ul id="prosList">
        <li>${_('Find materials shared by others')}</li>
        <li>${_('Get notifications about changes')}</li>
      </ul>
    </div>
    <div class="floatleft usergruperight">
      <form action="${url(controller='profile', action='subjects')}" method="GET"
            style="float: none">
        <fieldset>
          <legend class="a11y">${_('Watch subject')}</legend>
          <label><button value="submit" class="btnMedium"><span>${_('watch subjects')}</span></button>
          </label>
        </fieldset>
      </form>
      <div class="right_cross"><a id="hide_suggest_watch_subject" href="">${_('no, thanks')}</a></div>
    </div>
    <br class="clear-left" />
    <script type="text/javascript">
    //<![CDATA[
      $('#hide_suggest_watch_subject').click(function() {
          $(this).closest('.portlet').hide();
          $.post('${url(controller='profile', action='js_hide_element')}',
                 {type: 'hide_suggest_watch_subject'});
          return false;
      });
    //]]>
    </script>
  </%self:rounded_block>
%endif

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
