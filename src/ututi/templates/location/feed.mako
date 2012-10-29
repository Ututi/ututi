<%inherit file="/location/base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${h.javascript_link('/javascript/dashboard.js')}
</%def>

<%def name="body_class()">wall location-wall</%def>

%if c.show_discussion_form:
  <div id="dashboard_action_links" class="action active">
    <a class="action active location-discussion-action" id="add_wall_post_action" href="#add-wall-post">${_('Start a discussion')}</a>
  </div>

  <div id="dashboard_action_blocks">
    <div class="action-block" style="display: block;" id="add_wall_post_block">
      <div class="arrow-up"></div>
      <form method="POST" action="${url(controller='wall', action='create_location_wall_post')}" id="wallpost_form">
        <input id="add-wall-post-url" type="hidden" value="${url(controller='wall', action='create_location_wall_post_js')}" />
        <input type="hidden" name="location_id" id="location_id" value="${c.location.id}"/>
        <div class="action-tease"></div>
        <textarea name="post" class="tease-element"></textarea>
        ${h.input_submit(_('Send'), id="submit_wall_post", class_='dark inline action-button tease-element')}
        <a class="cancel-button tease-element" href="#cancel">${_("Cancel")}</a>
      </form>
    </div>
  </div>
%endif

<%def name="empty_discussions_location()">
  <div class="feature-box one-column icon-message">
    <div class="title">
      ${_("About discussions:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-discussions">
        <strong>${_("Start a discussion")}</strong>
        - ${_("discuss various topics. Both students and teachers from your university will be able to join the discussion.")}
      </div>
    </div>
    <div class="action-button">
      <button id="start-discussion-actionbutton">${_('Start a discussion')}</button>
    </div>
  </div>
</%def>

<%
  tip_dict = {'all': _('This is a list of all recent events in this university.'),
              'subjects': _('This is a list of all the recent events in the subjects and groups of this university.'),
              'discussions': _('This is a list of all recent discussions in this university.')}

  emptytext_dict = {'all': _('Sorry, nothing new at the moment.'),
                    'subjects': _('Sorry, no subject news the moment.'),
                    'discussions': "Sorry, no discussions for this university."}
%>
<div class="tip">
  ${tip_dict.get(c.current_tab, tip_dict['all'])}
</div>

${wall.wall_entries(c.events)}
%if not c.events:
<div id="empty-wall-notice">
  <p>${emptytext_dict.get(c.current_tab, emptytext_dict['all'])}</p>
  %if c.current_tab == 'discussions':
    ${empty_discussions_location()}
  %endif
</div>
%endif

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
            $(this).siblings('text-area.tease-element').focus();
        });

        $('#dashboard_action_blocks').show();
        /* Add wall post actions
         */
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
        $('#start-discussion-actionbutton').click(function () {
            $('#add_wall_post_block .action-tease').click();
            return false;
        });
    });
  </script>
