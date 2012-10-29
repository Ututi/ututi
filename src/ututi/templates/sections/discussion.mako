<%def name="discussion_form(action, target_field_name, target_id)">
  <div id="dashboard_action_links" class="action active">
    <a class="action active subject-discussion-action" id="add_wall_post_action" href="#add-wall-post">${_('Start a discussion')}</a>
  </div>

  <div id="dashboard_action_blocks">
    <div class="action-block" style="display: block;" id="add_wall_post_block">
      <div class="arrow-up"></div>
      <form method="POST" action="${action}" id="wallpost_form">
        <input id="add-wall-post-url" type="hidden" value="${url(controller='wall', action=action + '_js')}" />
        <input type="hidden" name="${target_field_name}" id="${target_field_name}" value="${target_id}"/>
        <div class="action-tease"></div>
        <textarea name="post" class="tease-element"></textarea>
        ${h.input_submit(_('Send'), id="submit_wall_post", class_='dark inline action-button tease-element')}
        <a class="cancel-button tease-element" href="#cancel">${_("Cancel")}</a>
      </form>
    </div>
  </div>
</%def>

<%def name="discussion_javascript()">
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
</%def>
