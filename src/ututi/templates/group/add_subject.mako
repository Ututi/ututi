<%inherit file="/group/home.mako" />
<%namespace file="/subject/add.mako" name="subject" />
<%namespace file="/group/add.mako" import="path_steps"/>

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/locationwidget.css')|n}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

% if c.step:
  <h1>${_('Group Subjects')}</h1>
  ${path_steps(1)}
% endif

<a class="back-link" href="${c.group.url(action='subjects_step')}">${_('back to Subject selection')}</a>
<h1>${_('New subject')}</h1>

<%subject:form action="${c.group.url(action='create_subject')}" />

<br />
<hr />
<a class="btn" href="${url(controller='group', action='invite_members_step', id=c.group.group_id)}" title="${_('Invite group members')}">
  <span>${_('Finish choosing subjects')}</span>
</a>
