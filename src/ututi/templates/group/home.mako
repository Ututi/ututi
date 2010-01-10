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
<div id="invite_more_members">
  <h4>Invite group members!</h4>
  <p>
    It's easy - you just have to know their email addresses! You can
    use the group mailing list together then!
  </p>
  <a class="btn-large" href="${c.group.url(action='members')}"><span>${_('Invite friends')}</span></a>
</div>
%endif

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
