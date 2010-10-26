$(document).ready(function(){
    $('.mailinglist_wall_reply').click(function() {
        form = $(this).closest('form');
        text = $("textarea[name='message']", form).val();
        if ($.trim(text) != '') {
            form.closest('.wall_item').addClass('loading');
            $.post(form.attr('action')+'?js=1',
              form.serialize(),
              function(data, status) {
                if (status == 'success') {
                  $('#wall').prepend($('<div class="action-reply">'+data+'</div>'));
                }
                $('.wall_item.loading').children('.action').fadeOut();
                $('.wall_item.loading').removeClass('loading');
              });
            return false;

            action = form.attr('action');
            data = form.serialize();
        }
        return false;
    });
});
