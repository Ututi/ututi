<%inherit file="/group/base.mako" />
%if c.welcome:
<h1 style="margin-top: 15px;">${_('Congratulations, you have created a new group!')}</h1>
<div style="margin: 10px 0;" class="group_description">
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
</div>
%endif

%if c.has_to_invite_members:
<div id="invite_more_members" class="full_box">
  <div class="wrapper">
    <div class="inner">
      <table>
        <tr>
          <td>
            <h2>${_("Invite group members!")}</h2>
            <div class="description">
              ${_("""
              It's easy - you just have to know their email addresses! You can
              use the group mailing list together then!
              """)}
            </div>
          </td>
          <td style="width: 170px; text-align: right;">
            ${h.button_to(_('Invite friends'), c.group.url(action='members'), class_='btnLarge')}
          </td>
        </tr>
      </table>
    </div>
  </div>
</div>
%endif

%if c.wants_to_watch_subjects:
<div id="watch_more_subjects" class="full_box">
  <div class="wrapper">
    <div class="inner">
      <table>
        <tr>
          <td>
            <h2>${_("Watch subjects you are studying!")}</h2>
            <div class="description">
              ${_("""
              Find the subjects your group is studying and add them to the list
              of watched subjects.  Upload files for the subjects without any
              limitations!
              """)}
            </div>
          </td>
          <td style="width: 170px; text-align: right;">
            <a class="btn-large" href="${c.group.url(action='subjects')}"><span>${_('Watch subjects')}</span></a>
            <br />
            <span style="padding-right: 5px;">
              <a href="${c.group.url(action='home', do_not_watch=True)}" class="cancel_link">${_('no, thank you')}</a>
            </span>
          </td>
        </tr>
      </table>
    </div>
  </div>
</div>
%endif

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
