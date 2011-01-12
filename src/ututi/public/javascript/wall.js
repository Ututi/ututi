$(document).ready(function(){

    /* Event removal.
     */
    $('.wall .wall-entry .event-heading .hide-button').click(function() {
        var form = $(this).closest('form');
        $.post(form.attr('action') + '?js=1',
               form.serialize(),
               function(data) {
                   type = $('input.event-type', form).val();
                   $('.type_' + type).fadeOut(500);
               });
        return false;
    });

    /* Event hiding.
     */
    $('.wall .wall-entry .event-heading').click(function(event) {
        if ($(event.target).is('a')) {
            // default behavior if clicked on a link
        }
        else {
            var body = $(this).closest('.wall-entry').find('.event-body');
            if (body.is(':visible'))
                body.slideUp('fast');
            else
                body.slideDown('fast');
            return false;
        }
    });

    /* Show/hide reply forms.
     */
    $('.wall .wall-entry .action-block-link').click(function() {
        var entry = $(this).closest('.wall-entry');
        $(entry).find('.action-block').show();
        $(entry).find('.action-block textarea').focus();
        return false;
    });

    $('.wall .wall-entry .action-block-cancel').click(function() {
        var entry = $(this).closest('.wall-entry');
        $(entry).find('.action-block').hide();
        return false;
    });

    /*
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

    */
});
