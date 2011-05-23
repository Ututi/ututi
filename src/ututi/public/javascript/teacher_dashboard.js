$(document).ready(function() {

    $('.unteach-button').click(function() {
      var actionurl = this.href + '&js=1';
      var container = $(this).closest('.subject-description');
      $.post(actionurl, function(status) {
        if (status == 'OK')
          container.slideUp('fast', function() {
            $(this).remove();
          });
      });
      return false;

    $('.group-description .click-action').click(function() {
        id = $(this).attr('id');
        if ($(this).hasClass('open')) {
            $(this).removeClass('open');
            $('#' + id + '-block').slideUp(300);
        } else {
            $(this).closest('.group-description').find('a.click-action.open').each(function(){
                $(this).removeClass('open');
                var cls_id = $(this).attr('id');
                $('#' + cls_id + '-block').slideUp(300);
            });
            $(this).addClass('open');
            $('#' + id + '-block').slideDown(300);
        }
        return false;
    });

    $('.message_send').click(function(){
        var form = $(this).closest('form');
        var message_send_url = $(".message_send_url", form).val();
        subject = $('.message_subject', form).val();
        message = $('.message', form).val();

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
                                   container = $(form).closest('.group-description');
                                   $('.send_message', container).click();
                                   $('.message-sent', container).removeClass('hidden');
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
