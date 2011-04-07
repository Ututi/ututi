$(document).ready(function(){

    /* Event removal.
     */
    $('.wall .wall-entry .event-heading .hide-button').live('click', function() {
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
    $('.wall .wall-entry.minimizable .event-heading').live('click', function(event) {
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
    $('.wall .wall-entry .action-block-link, ' +
      '.wall .wall-entry .action-tease').live('click', function() {
        var entry = $(this).closest('.wall-entry, .wall-subentry');
        entry.find('.action-tease').hide();
        entry.find('.action-block').show();
        entry.find('.action-block textarea').focus();
        return false;
    });

    $('.wall .wall-entry .action-block-cancel').live('click', function() {
        var entry = $(this).closest('.wall-entry, .wall-subentry');
        entry.find('.action-block').hide();
        entry.find('.action-block textarea').val('');
        entry.find('.action-tease').show();
        return false;
    });

    /* AJAX for reply actions.
     */
    $('.wall .wall-entry .action-block .reply-button').click(function() {
        var form = $(this).closest('form');
        var text = form.find('.reply-text');
        if ($.trim(text.val()) != '') {
            $.post(
                form.attr('action') + '?js=1',
                form.serialize(),
                function(content) {
                    form.closest('.action-block').hide();
                    form.closest('.reply').find('.action-tease').show();
                    text.val('');
                    var replies = form.closest('.wall-entry, .wall-subentry').find('.replies');
                    $(content).hide().appendTo(replies).fadeIn('slow');
                }
            );
        }
        fire_analytics_event(this);
        return false;
    });

    function fire_analytics_event(button_clicked) {
        /* Fire Google Analytics event with
         * parameters extracted via reflection.
         */
        var category = 'wall';
        var action = 'reply/comment';
        var label = 'undefined';

        // pick category
        if ($(button_clicked).closest('.profile-wall').length)
            category = 'profile wall';
        else if ($(button_clicked).closest('.subject-wall').length)
            category = 'subject wall';
        else if ($(button_clicked).closest('.group-wall').length)
            category = 'group wall';
        else if ($(button_clicked).closest('.location-wall').length)
            category = 'location wall';

        // pick label
        var entry = $(button_clicked).closest('.wall-entry');
        classes = entry.attr('class').split(' ');
        for (var i = 0; i < classes.length; i++)
            if (classes[i].substr(0, 5) == 'type_')
                label = classes[i];

        _gaq.push(['_trackEvent', category, action, label]);
    }

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
