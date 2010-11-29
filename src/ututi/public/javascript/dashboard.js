/* Wall dashboard javascript.
 *
 * Current implementation assumes that there's only
 * one dashboard on the page. This is not very hard
 * to fix: see global variable usage.
 */

$(document).ready(function() {

    /* Hide action blocks.
     *
     * Currently they are initially hidden in CSS.
     * It would be nice to fall back if JS not available though.

    $('#dashboard_action_blocks .dashboard_action_block').hide()

     */

    /* Attach dashboard actions.
     */
    $('#dashboard_actions a.action').click(function(){
        var id = $(this).attr('id');
        if ($(this).hasClass('open')) {
            $(this).removeClass('open');
            $('#' + id + '_block').slideUp(300);
        } else {
            $('#dashboard_actions a.open').each(function(){
                $(this).removeClass('open');
                var cls_id = $(this).attr('id');
                $('#' + cls_id + '_block').slideUp(300);
            });
            $(this).addClass('open');
            $('#' + id + '_block').slideDown(300);
        }
        return false;
    });

    /* Helper reload function.
     */
    wall_reload_url = $("#wall-reload-url").val();
    function reload_wall() {
        $('#wall').load(wall_reload_url);
    };

    /* Send message actions.
     */
    message_rcpt_url = $("#message-rcpt-url").val();
    $('#rcpt').autocomplete({
        source: function(request, response) {
            $.getJSON(message_rcpt_url,
                      request, function(data, status, xhr) {
                          response(data.data);
                      });
        },
        minLength: 2,
        select: function(event, ui) {
            $(this).closest('form').find('#rcpt_id').val(ui.item.id);
            sel = $('#category_id');
            sel = sel[0];
            if (ui.item.hasOwnProperty('categories') && ui.item.categories != []) {
                sel.options.length = 0;
                $.each(ui.item.categories, function() {
                    sel.options[sel.options.length] = new Option(this.title, this.value);
                });
                if (sel.options.length > 1) {
                  $(sel).closest('.formField').show();
                }
            } else {
                $(sel).hide();
            }
        }
    });

    message_send_url = $("#message-send-url").val();
    $('#message_send').click(function(){
        form = $(this).closest('form');

        subject = $('#message_subject', form).val();
        message = $('#message', form).val();

        if ((subject != '') && (message != '')) {
            $.post(message_send_url,
                   $(this).closest('form').serialize(),
                   function(data, status) {
                       if (data.success != true) {
                           for (var key in data.errors) {
                               var error = data.errors[key];
                               $('#'+key).parent().after($('<div class="error-message">'+error+'</div>'));
                           }
                       } else {
                           $('#message_form').find('input, textarea').val('');
                           $('#send_message').click();
                           reload_wall();
                       }
                   },
                   "json");
        }
        return false;
    });

    /* File upload actions.
     */
    if ($("#file_upload_block").length > 0) {

        file_upload_url = $("#file-upload-url").val();
        $('#file_upload_submit').click(function(){return false;});
        var file_upload = new AjaxUpload($('#file_upload_submit'),
            {action: file_upload_url,
             name: 'attachment',
             data: {folder: '', target_id: $('#file_rcpt_id').val()},
             onSubmit: function(file, ext, iframe){
                 iframe['progress_indicator'] = $(document.createElement('div'));
                 $('#upload_file_block').append(iframe['progress_indicator']);
                 iframe['progress_indicator'].text(file);
                 iframe['progress_ticker'] = $(document.createElement('span'));
                 iframe['progress_ticker'].appendTo(iframe['progress_indicator']).text(' Uploading');
                 var progress_ticker = iframe['progress_ticker'];
                 var interval;

                 // Uploding -> Uploading. -- Uploading...
                 interval = window.setInterval(function(){
                     var text = progress_ticker.text();
                     if (text.length < 13){
                         progress_ticker.text(text + '.');
                     } else {
                         progress_ticker.text('Uploading');
                     }
                 }, 200);
                 iframe['interval'] = interval;
             },
             onComplete: function(file, response, iframe){
                 if (response != 'UPLOAD_FAILED') {
                     iframe['progress_indicator'].remove();
                     $('#file_upload_form').find('input, textarea').val('');
                     $('#upload_file').click();
                     $('#upload_file_block').removeClass('upload-failed');
                     reload_wall();
                 } else {
                     $('#upload_file_block').addClass('upload-failed');
                 }
                 window.clearInterval(iframe['interval']);
             }
            });
        $('#file_rcpt_id').change(function(){
            file_upload.setData({folder: '', target_id: $(this).val()});
        });

    }

    /* Create wiki actions.
     */
    create_wiki_url = $("#create-wiki-url").val();
    $('#wiki_create_send').click(function(){
        form = $(this).closest('form');

        for ( instance in CKEDITOR.instances )
            CKEDITOR.instances[instance].updateElement();


        title = $('#page_title', form).val();
        content = $('#page_content', form).val();

        if ((title != '') && (content != '')) {
            $.post(create_wiki_url,
                   $(this).closest('form').serialize(),
                   function(data, status) {
                       if (data.success != true) {
                           for (var key in data.errors) {
                               var error = data.errors[key];
                               $('#'+key).parent().after($('<div class="error-message">'+error+'</div>'));
                           }
                       } else {
                           $('#wiki_form').find('input, textarea').val('');
                           $('#create_wiki').click();
                           reload_wall();
                       }
                   },
                   "json");
        }
        return false;
    });

});
