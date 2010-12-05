$(document).ready(function(){
    var approve_reject = function(button){
      var panel = $(button).closest('.moderation-actions');
      panel.addClass('loading');
      $.ajax({
        url: $(button).closest('form').attr('action') + '?js=1',
        success: function(data) {
          panel.removeClass('loading');
          panel.removeClass('error');
          panel.html(data);
          panel.closest('.message-list-on1, .message-list-off1, .wall_item')
            .find('a').addClass('disabled').removeAttr('href');
          reload_whitelist();
        },
        error: function(data) {
          panel.removeClass('loading');
          panel.addClass('error');
        }
      });
    };

    var reload_whitelist = function(button){
      var whitelist = $('.group-whitelist');
      whitelist.addClass('loading');
      var action_url = $('#whitelist_email_form #reload_url').val();
      $.ajax({
        url: action_url,
        success: function(data) {
            $('.group-whitelist').html(data);
        },
        error: function(data) {
        }
      });
    };

  $('.btn-approve').click(function() {
      approve_reject(this);
      return false;
  });

  $('.btn-reject').click(function() {
      approve_reject(this);
      return false;
  });
});
