<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>

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
    $('#upload_file_block .cancel-button').click(function() {
        $('#upload_file').click();
        clearBlock($(this).closest('.action-block'));
    });
    $('#create_wiki_block .cancel-button').click(function() {
        $('#create_wiki').click();
        clearBlock($(this).closest('.action-block'));
    });

    /* File upload actions.
     */
    file_upload_url = $("#file-upload-url").val();
    $('#file_upload_submit').click(function(){return false;});
    var file_upload = new AjaxUpload($('#file_upload_submit'),
        {action: file_upload_url,
         name: 'attachment',
         data: {folder: $('#folder').val(), target_id: $('#file_rcpt').val()},
         onSubmit: function(file, ext, iframe){
             _gaq.push(['_trackEvent', 'subject wall', 'action block submit', 'file upload']);
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

    /* Create wiki actions.
     */
    $('#wiki_create_send').click(function(){
        _gaq.push(['_trackEvent', 'subject wall', 'action block submit', 'wiki create']);
        create_wiki_url = $("#create-wiki-url").val();
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
                           $('#create_wiki_block .cancel-button').click();
                           reload_wall(data.evt);
                       }
                   },
                   "json");
        }
        return false;
    });
  });
  </script>
</%def>

<%def name="upload_file_block(subject)">
  <div id="upload_file_block" class="action-block">
    <a name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js')}" />
      <input id="file_rcpt" type="hidden" value="${subject.id}"/>
      %if len(subject.folders) > 1:
        <% folders = [(f.title, f.title != '' and f.title or _('Root')) for f in subject.folders] %>
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

<%def name="create_wiki_block(subject)">
  <div id="create_wiki_block" class="action-block">
    <a class="${'active' if active else 'inactive'}" name="create-wiki"></a>
    <form method="POST" action="${url(controller='wall', action='create_wiki')}" id="wiki_form" class="inelement-form">
      <input id="create-wiki-url" type="hidden" value="${url(controller='wall', action='create_wiki_js')}" />
      <input type="hidden" name="rcpt_wiki" value="${subject.id}" />
      <div class="action-tease">${_("Write note title here")}</div>
      <input id="page_title" type="text" name="page_title" class="tease-element" />
      ${h.input_wysiwyg('page_content', '')}
      ${h.input_submit(_('Save'), id="wiki_create_send", class_='dark inline action-button')}
      <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
</%def>

<%def name="action_block(subject)">
  <%actions:action_block>
    <%def name="links()">
      <a class="action active" id="upload_file" href="#upload-file">${_('File')}</a>
      <a class="action active" id="create_wiki" href="#create-wiki">${_('Wiki note')}</a>
    </%def>

    ${self.upload_file_block(subject)}
    ${self.create_wiki_block(subject)}
  </%actions:action_block>
</%def>
