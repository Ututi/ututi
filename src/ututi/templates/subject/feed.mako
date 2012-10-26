<%inherit file="/subject/base_two_sidebar.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />
<%namespace name="actions" file="/subject/wall_actionblock.mako" import="action_block, head_tags"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${actions.head_tags()}
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
${actions.action_block(c.subject)}
%endif

%if c.events:
  ${wall.wall_entries(c.events)}
%else:
  %if c.current_tab == 'discussions':
    ${empty_discussions_subject()}
  %endif
%endif
<script type="text/javascript">
$(function () {
    $('#start-discussion-actionbutton').click(function () {
        $('#add_wall_post.action').click();
        $('#add_wall_post_block .action-tease').click();
    });
});
</script>
