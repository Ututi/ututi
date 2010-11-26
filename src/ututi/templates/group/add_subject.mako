<%inherit file="/group/base.mako" />
<%namespace file="/subject/add.mako" name="subject" />
<%namespace file="/group/create_base.mako" import="path_steps"/>

<%def name="title()">
${_('New subject')}
</%def>

<%def name="head_tags()">
    ${parent.head_tags()}
    <%subject:head_tags />
</%def>

% if c.step:
  <h1>${_('Group Subjects')}</h1>
  ${path_steps(1)}

<a class="back-link" href="${c.group.url(action='subjects_step')}">${_('back to Subject selection')}</a>
<h1>${_('New subject')}</h1>

<%subject:form action="${c.group.url(action='create_subject_step')}" />

<br />
<hr />
<a class="btn" href="${url(controller='group', action='invite_members_step', id=c.group.group_id)}" title="${_('Invite group members')}">
  <span>${_('Finish choosing subjects')}</span>
</a>
% else:
<a class="back-link" href="${c.group.url(action='subjects')}">${_('back to Subject selection')}</a>
<h1>${_('New subject')}</h1>

<%subject:form action="${c.group.url(action='create_subject')}" />
% endif
