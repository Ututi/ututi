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
    <form name="discussion-form" id="discussion-form" action="/wall/start_discussion" method="POST">
      <textarea id="message-text" name="message-text"></textarea>
      <button class="dark inline action-button submit" value="Send">Send</button>
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
    $('#message-text').click(function() {
        $(this).css('min-height', '40px');
    });
    $('#message-text').focus();
</script>
