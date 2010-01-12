<%inherit file="/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<%def name="portlets()">
${group_sidebar()}
</%def>

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
          <td style="width: 120px;">
            <a class="btn-large" href="${c.group.url(action='members')}"><span>${_('Invite friends')}</span></a>
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
          <td style="width: 120px; text-align: right;">
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
