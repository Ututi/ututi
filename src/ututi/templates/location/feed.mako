<%inherit file="/location/base.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<%def name="body_class()">wall location-wall</%def>

<div id="dashboard_action_links">
  <div id="start-discussion">Start discussion</div>
</div>

<div id="dashboard_action_blocks">
  <div class="action-block">
    <div class="arrow-up"></div>
    <form id="discussion-form" action="${url(controller='wall', action='send_wall_message')}" method="POST">
      <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_wall_message_js')}">
      <textarea id="message" name="message"></textarea>
      <button id="message_send" class="dark inline action-button submit" value="Send">Send</button>
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

<script>
    $('#discussion_action_blocks').show();
    $('.action-block').show();
    $('#message').click(function() {
        $(this).css('min-height', '40px');
    });

    $('#message').focus();

    $('#message_send').click(function() {
        _gaq.push(['_trackEvent', 'group wall', 'action block submit', 'message send']);
        form = $(this).closest('form');
        message = $('#message', form).val();
        message_send_url = $('#message-send-url', form).val();

        if (message != '') {
            $.post(message_send_url,
                $(this).closest('form').serialize(),
                    function(data, status) {
                        if (data.success != true) {
                            for (var key in data.errors) {
                                var error = data.errors[key];
                                $('#'+key).parent().after($('<div class="error-message">'+error+'</div>'));
                            }
                        } else {
                            $('#send_message_block .cancel-button').click();
                            reload_wall(data.evt);
                        }
                    },
            "json");
        }

        return false;  
    });  
</script>
