$(document).ready(function(){
    $('.mailinglist_wall_reply').click(function(evt) {
        evt.stopPropagation();
        var form = $(this).closest('form');
        var text = $("textarea[name='message']", form).val();

        if ($.trim(text) != '') {
            form.closest('.wall_item').addClass('loading');
            var event_snippet = $(this).closest('.wall_item');
            $.post(form.attr('action')+'?js=1',
              form.serialize(),
              function(data, status) {
                  return function() {
                      if (status == 'success') {
                          $('.action', event_snippet).fadeOut().replaceWith($('<div class="action-reply">'+data+'</div>'));
                      }
                  }(data, status, event_snippet);
              }

            );
            return false;

            action = form.attr('action');
            data = form.serialize();
        }
        return false;
    });
});
