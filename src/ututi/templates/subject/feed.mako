<%inherit file="/subject/base_two_sidebar.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />
<%namespace name="actions" file="/subject/wall_actionblock.mako" import="action_block, head_tags"/>
<%namespace name="discussion" file="/sections/discussion.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  %if c.current_tab == 'discussions':
    ${h.javascript_link('/javascript/dashboard.js')}
  %else:
    ${actions.head_tags()}
  %endif
</%def>

<%def name="empty_discussions_subject()">
  <div class="feature-box one-column icon-message">
    <div class="title">
      ${_("About discussions:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-discussions">
        <strong>${_("Start a discussion")}</strong>
        - ${_("discuss various topics. Students and teachers who follow this subject will be able to join the discussion.")}
      </div>
    </div>
    <div class="action-button">
      <button id="start-discussion-actionbutton">${_('Start a discussion')}</button>
    </div>
  </div>
</%def>

<%def name="body_class()">wall subject-wall</%def>

%if c.user:
  %if c.current_tab == 'discussions':
    ${discussion.discussion_form("create_subject_wall_post", "subject_id", c.subject.id)}
    ${discussion.discussion_javascript()}
  %else:
    ${actions.action_block(c.subject)}
  %endif
%endif

${wall.wall_entries(c.events)}
%if not c.events:
<div id="empty-wall-notice">
  %if c.current_tab == 'discussions':
    ${empty_discussions_subject()}
  %endif
</div>
%endif

