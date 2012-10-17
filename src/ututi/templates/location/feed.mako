<%inherit file="/location/base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
  ${h.javascript_link('/javascript/dashboard.js')}
</%def>

<%def name="body_class()">wall location-wall</%def>

  <div id="dashboard_action_links" class="action active">
    <a class="action active" id="add_wall_post_action" href="#add-wall-post">${_('Start discussion')}</a>
  </div>

  <div id="dashboard_action_blocks">
    <div class="action-block" id="add_wall_post_block">
      <div class="arrow-up"></div>
      <form method="POST" action="${url(controller='wall', action='create_location_wall_post')}" id="wallpost_form">
        <input id="add-wall-post-url" type="hidden" value="${url(controller='wall', action='create_location_wall_post_js')}" />
        <input type="hidden" name="location_id" id="location_id" value="${c.location.id}"/>
        <div class="action-tease">${_("What you want to discuss...")}</div>
        <textarea name="post" class="tease-element"></textarea>
        ${h.input_submit(_('Send'), id="submit_wall_post", class_='dark inline action-button')}
        <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
      </form>
    </div>
  </div>

<div class="tip">
  ${_('This is a list of all the recent events in the subjects and groups of this university.')}
</div>

%if c.events:
  ${wall.wall_entries(c.events)}
%else:
  ${_('Sorry, nothing new at the moment.')}
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
                            }
                       }
                );
            }
            return false;
        });

      $('#add_wall_post_action').click(function () {
          $('#add_wall_post_block').toggle();
      });
    });
  </script>
