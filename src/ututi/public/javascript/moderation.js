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
            panel.removeClass('loading');
            panel.removeClass('error');
            $('.group-whitelist').html(data);
        },
        error: function(data) {
          panel.removeClass('loading');
          panel.addClass('error');
        }
      });
    };

  $('.btn-approve').click(function() {
      approve_reject(this);
      reload_whitelist();
      return false;
  });

  $('.btn-reject').click(function() {
      approve_reject(this);
      return false;
  });
});
