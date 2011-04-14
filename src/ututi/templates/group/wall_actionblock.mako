<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/elements.mako" import="tooltip" />

<%def name="head_tags()">
  ${actions.head_tags()}
  <script type="text/javascript">
  $(function(){
    function clearBlock(block) {
        block.find('input[type="text"], textarea').val('');
        block.find('.tease-element').hide();
        block.find('.action-tease').show();
        block.find('.error-message').hide();
    }
    /* Send message actions.
     */
    $('#send_message_block .cancel-button').click(function() {
        $('#send_message').click();
        clearBlock($(this).closest('.action-block'));
        return false;
    });
    $('#upload_file_block .cancel-button').click(function() {
        $('#upload_file').click();
        clearBlock($(this).closest('.action-block'));
    });

    message_send_url = $("#message-send-url").val();
    $('#message_send').click(function(){
        _gaq.push(['_trackEvent', 'group wall', 'action block submit', 'message send']);
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
                           $('#send_message_block .cancel-button').click();
                           reload_wall(data.evt);
                       }
                   },
                   "json");
        }
        return false;
    });

    /* File upload actions.
     */
    if ($("#upload_file_block").length > 0) {

        file_upload_url = $("#file-upload-url").val();
        $('#file_upload_submit').click(function(){return false;});
        var file_upload = new AjaxUpload($('#file_upload_submit'),
            {action: file_upload_url,
             name: 'attachment',
             data: {folder: $('#folder').val(), target_id: $('#file_rcpt').val()},
             onSubmit: function(file, ext, iframe){
                 _gaq.push(['_trackEvent', 'group wall', 'action block submit', 'file upload']);
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
                 iframe['progress_indicator'].remove();
                 if (response != 'UPLOAD_FAILED') {
                     $('#file_upload_submit .cancel-button').click();
                     reload_wall(response);
                 } else {
                     $('#upload-failed-error-message').fadeIn(500);
                 }
                 window.clearInterval(iframe['interval']);
             }
            });
        $('#folder').change(function(){
            file_upload.setData({folder: $(this).val(), target_id: $('#file_rcpt').val()});
        });

    }
  });
  </script>
</%def>

<%def name="send_message_block(group)">
  <div id="send_message_block" class="action-block">
    <a name="send-message"></a>
    <form method="POST" action="${url(controller='wall', action='send_message')}" id="message_form" class="inelement-form">
      <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_message_js')}" />
      <input type="hidden" name="group_id" id="group_id" value="${group.id}"/>
      <div class="action-tease">${_("Write your topic")}</div>
      <input id="message_subject" type="text" name="subject" class="tease-element" />
      <textarea name="message"></textarea>
      ${h.input_submit(_('Send'), id="message_send", class_='dark inline action-button')}
      <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
</%def>

<%def name="upload_file_block(group)">
  <div id="upload_file_block" class="action-block">
    <a name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js')}" />
      <input id="file_rcpt" type="hidden" value="${group.id}"/>
      %if len(group.folders) > 1:
        <% folders = [(f.title, f.title != '' and f.title or _('Root')) for f in group.folders] %>
        ${h.select('folder', [], folders)}
      %else:
        <input type='hidden' name='folder' value=''/>
      %endif
      ${h.input_submit(_('Upload file'), id="file_upload_submit", class_='dark inline action-button')}
      <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
  <div id="upload-failed-error-message" class="action-reply">${_('File upload failed.')}</div>
</%def>

<%def name="wall_reload_url()">
  ## Hidden action url, used to ajax-refresh the wall.
  <input id="wall-reload-url" type="hidden" value="${url(controller='group', action='feed_js', id=c.group.group_id)}" />
</%def>

<%def name="action_block(group)">
  <%
  show_messages = True
  show_files = group.has_file_area and group.upload_status != group.LIMIT_REACHED
  %>
  <%actions:action_block>
    <%def name="links()">
      <a class="action ${'active' if show_messages else 'inactive'}" id="send_message" href="#send-message">${_('Group message')}</a>
      %if not show_files:
      ${tooltip(_('This group does not have a file area of has reached its limits.'))}
      %endif
      <a class="action ${'active' if show_files else 'inactive'}" id="upload_file" href="#upload-file">${_('File')}</a>
    </%def>

    ${self.send_message_block(group)}
    ${self.upload_file_block(group)}

  </%actions:action_block>
</%def>
