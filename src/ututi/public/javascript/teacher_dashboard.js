$(document).ready(function() {

    $('.group-description .action-link').click(function() {
        var group = $(this).closest('.group-description')
        $('.action-block:visible').slideUp('fast');
        if ($(this).hasClass('email'))
            group.find('.email.action-block:hidden').slideDown('fast');
        else if ($(this).hasClass('sms'))
            group.find('.sms.action-block:hidden').slideDown('fast');
        return false;
    });

    $('.message-send').click(function(){
        var form = $(this).closest('form');
        var message_send_url = $(".message-send-url", form).val();
        var subject = $('.message-subject', form).val();
        var message = $('.message', form).val();

        if ((subject != '') && (message != '')) {
            form.ajaxSubmit({
                url: message_send_url,
                iframe: true,
                dataType: 'json',
                success: function(data, status) {
                   return function() {
                       if (data.success != true) {
                           for (var key in data.errors) {
                               var error = data.errors[key];
                               $('.'+key, form).parent().after($('<div class="error-message">'+error+'</div>'));
                           }
                       } else {
                           $(form).find('input[type!="hidden"], textarea').val('');
                           var container = $(form).closest('.group-description');
                           $('.email.action-link', container).click();
                           $('.message-sent', container).show().delay(3000).fadeOut();
                       }
                   }(data, status, form);
                }
            });
        }
        return false;
    });

    //sms ajax send
    $('.sms-box .send_button').click(function() {
        var form = $(this).closest('form');
        url = $(form).attr('action') + '?js=1';
        $.post(url,
               form.serialize(),
               function(data, status) {
                   return function() {
                       $(form).find('input[type="text"], textarea').val('');
                       container = $(form).closest('.group-description');
                       $('.send_sms', container).click();
                       $('.sms-sent', container).removeClass('hidden');
                   }(data, status, form)
               }
              );
        return false;

    });

});
