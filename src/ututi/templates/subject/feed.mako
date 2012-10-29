<%inherit file="/subject/base_two_sidebar.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />
<%namespace name="actions" file="/subject/wall_actionblock.mako" import="action_block, head_tags"/>

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

<%def name="discussion_form()">
  <div id="dashboard_action_links" class="action active">
    <a class="action active subject-discussion-action" id="add_wall_post_action" href="#add-wall-post">${_('Start a discussion')}</a>
  </div>

  <div id="dashboard_action_blocks">
    <div class="action-block" style="display: block;" id="add_wall_post_block">
      <div class="arrow-up"></div>
      <form method="POST" action="${url(controller='wall', action='create_subject_wall_post')}" id="wallpost_form">
        <input id="add-wall-post-url" type="hidden" value="${url(controller='wall', action='create_subject_wall_post_js')}" />
        <input type="hidden" name="subject_id" id="subject_id" value="${c.subject.id}"/>
        <div class="action-tease"></div>
        <textarea name="post" class="tease-element"></textarea>
        ${h.input_submit(_('Send'), id="submit_wall_post", class_='dark inline action-button tease-element')}
        <a class="cancel-button tease-element" href="#cancel">${_("Cancel")}</a>
      </form>
    </div>
  </div>
</%def>

<%def name="body_class()">wall subject-wall</%def>

%if c.user:
  %if c.current_tab == 'discussions':
    ${discussion_form()}
    <%doc>
      TODO move this javascript to discussions.js or something similar
    </%doc>
    <script type="text/javascript">
    $(function () {
        function clearBlock(block) {
            block.find('input[type="text"], textarea').val('');
            block.find('.tease-element').hide();
            block.find('.action-tease').show();
            block.find('.error-message').hide();
        }
        $('#add_wall_post_block .cancel-button').click(function() {
            $('#add_wall_post').click();
            clearBlock($(this).closest('.action-block'));
            return false;
        });
        $('#add_wall_post_block .action-tease').click(function() {
            $(this).closest('.action-tease').hide();
            $(this).siblings('.tease-element').show();
            $(this).siblings('textarea.tease-element').focus();
        });
        $('#start-discussion-actionbutton').click(function () {
            $('#add_wall_post_block .action-tease').click();
            return false;
        });
        add_wall_post_url = $("#add-wall-post-url").val();
        $("#submit_wall_post").click(function () {
            form = $(this).closest('form');
            post = $("#post", form).val();
            if (post != '') {
                $.post(add_wall_post_url,
                       $(this).closest('form').serialize(),
                       function (data, status) {
                            if (data.success != true) {
                               for (var key in data.errors) {
                                   var error = data.errors[key];
                                   $('#'+key).parent().after($('<div class="error-message">'+error+'</div>'));
                               }
                            } else {
                                $('#add_wall_post_block .cancel-button').click();
                                reload_wall(data.evt);
                                $('#empty-wall-notice').hide();
                            }
                       }
                );
            }
            return false;
        });
    });
    </script>
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

