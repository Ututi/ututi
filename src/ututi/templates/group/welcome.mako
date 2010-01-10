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

<h1>${_('Congratulations, you have created a new group!')}</h1>

<p>
${h.literal(_("""
Ututi groups are a communication tool for you and your friends. Here
your group can use the <a href="%(link_to_forums)s">forums</a>, keep
private files and <a href="%(link_to_subjects)s">watch subjects</a>
you are studying.
""") % dict(link_to_forums=c.group.url(action='forum'),
            link_to_subjects=c.group.url(action='subjects')))}

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
