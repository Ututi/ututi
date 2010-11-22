$(document).ready(function(){
  $('.btn-accept, .btn-reject').click(function() {
      var panel = $(this).closest('.moderation-actions');
      panel.addClass('loading');
      $.ajax({
        url: $(this).closest('form').attr('action') + '?js=1',
        success: function(data) {
          panel.removeClass('loading');
          panel.removeClass('error');
          panel.html(data);
          panel.closest('.message-list-on1, .message-list-off1, .wall_item')
            .find('a').addClass('disabled').removeAttr('href');
        },
        error: function(data) {
          panel.removeClass('loading');
          panel.addClass('error');
        }
      });
      return false;
  });
});
