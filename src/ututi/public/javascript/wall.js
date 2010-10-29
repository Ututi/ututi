$(document).ready(function(){
    $('.hide_event').click(function() {
        form = $(this).closest('form');
        $.post(form.attr('action')+'?js=1',
               form.serialize(),
               function(data, status) {
                   return function() {
                       if (status == 'success') {
                           type = $('input.event_type', form).val();
                           $('.type_'+type).fadeOut(500);
                       }
                   }(data, status, form);
               });
        return false;
    });
    $('.action_submit').click(function(evt) {
        evt.stopPropagation();
        var form = $(this).closest('form');
        var event_snippet = $(this).closest('.wall_item');
        if ($(event_snippet).hasClass('sms_sent')) {
            var text = $("textarea[name='sms_message']", form).val();
        } else {
            var text = $("textarea[name='message']", form).val();
        }

        if ($.trim(text) != '') {
            form.closest('.wall_item').addClass('loading');
            $.post(form.attr('action')+'?js=1',
              form.serialize(),
              function(data, status) {
                  return function() {
                      if (status == 'success') {
                          $(form).closest('.wall_item').removeClass('loading');
                          $(form).closest('.action').fadeOut().replaceWith($('<div class="action-reply">'+data+'</div>'));
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
