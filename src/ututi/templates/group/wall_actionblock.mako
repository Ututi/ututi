<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace name="dropdown" file="/widgets/dropdown.mako" import="dropdown, head_tags"/>
<%namespace file="/elements.mako" import="tooltip" />

<%def name="head_tags()">
  ${actions.head_tags()}
  ${dropdown.head_tags()}
  <script type="text/javascript">
  $(function(){
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
                           $('#message_form').find('input[type="text"], textarea').val('');
                           $('#send_message').click();
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
             data: {folder: $('#folder-select').val(), target_id: $('#file_rcpt').val()},
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
                     $('#file_upload_form').find('input[type="text"], textarea').val('');
                     $('#upload_file').click();
                     $('#upload_file_block').removeClass('upload-failed');
                     reload_wall(response);
                 } else {
                     $('#upload-failed-error-message').fadeIn(500);
                 }
                 window.clearInterval(iframe['interval']);
             }
            });
        $('#folder-select').change(function(){
            file_upload.setData({folder: $(this).val(), target_id: $('#file_rcpt').val()});
        });

    }
  });
  </script>
</%def>

<%def name="send_message_block(group)">
  <%base:rounded_block id="send_message_block" class_="dashboard_action_block">
    <a name="send-message"></a>
    <form method="POST" action="${url(controller='wall', action='send_message')}" id="message_form" class="inelement-form">
      <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_message_js')}" />
      <input type="hidden" name="rcpt_group" id="rcpt_id" value="${group.id}"/>
      ${h.input_line('subject', _('Message subject:'), id="message_subject", class_='wide-input')}
      <div class="formArea">
        <label>
          <span class="labelText">${_('Message text:')}</span>
          <textarea name="message" id="message" rows="5" rows="50"></textarea>
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Send'), id="message_send")}
      </div>
    </form>
  </%base:rounded_block>
</%def>

<%def name="upload_file_block(group)">
  <%base:rounded_block id="upload_file_block" class_="dashboard_action_block">
    <a name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js')}" />
      <input id="file_rcpt" type="hidden" value="${group.id}"/>
      %if len(group.folders) > 1:
        <%
           folders = [(f.title, f.title != '' and f.title or _('Root')) for f in group.folders]
        %>
        ${dropdown.dropdown('folder', _('Folder:'), folders)}
      %else:
        <input type='hidden' name='folder' value=''/>
      %endif
      <br class="clearBoth"/>
      <div class="formSubmit">
        ${h.input_submit(_('Upload file'), id="file_upload_submit")}
      </div>

    </form>

  </%base:rounded_block>
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
      ${tooltip(_('You need to be a member of a group or have subjects that you are studying to be able to quickly upload files.'))}
      %endif
      <a class="action ${'active' if show_files else 'inactive'}" id="upload_file" href="#upload-file">${_('File')}</a>
    </%def>

    ${self.send_message_block(group)}
    ${self.upload_file_block(group)}

  </%actions:action_block>
</%def>
