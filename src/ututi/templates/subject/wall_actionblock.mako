<%doc>
  Wall actionblock for the user's wall.
</%doc>

<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace name="dropdown" file="/widgets/dropdown.mako" import="dropdown, head_tags"/>

<%def name="head_tags()">
  ${actions.head_tags()}
  ${dropdown.head_tags()}
  <script type="text/javascript">
  $(function(){
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
                     $('#file_upload_form').find('input, textarea').val('');
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

<%def name="upload_file_block(subject)">
  <%base:rounded_block id="upload_file_block" class_="dashboard_action_block">
    <a name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js')}" />
      <input id="file_rcpt" type="hidden" value="${subject.id}"/>
      %if len(subject.folders) > 1:
        <%
           folders = [(f.title, f.title != '' and f.title or _('Root')) for f in subject.folders]
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

<%def name="action_block(subject)">
  <%actions:action_block>
    <%def name="links()">
      <a class="action" id="upload_file" href="#upload-file">${_('upload a file')}</a>
    </%def>

    ${self.upload_file_block(subject)}

  </%actions:action_block>
</%def>
