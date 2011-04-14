<%doc>
  Wall actionblock for the user's wall.
</%doc>

<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/elements.mako" import="tooltip" />

<%def name="css()">
#rcpt_user-field { display: none; }
</%def>

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
    $('#create_wiki_block .cancel-button').click(function() {
        $('#create_wiki').click();
        clearBlock($(this).closest('.action-block'));
    });

    message_send_url = $("#message-send-url").val();

    $('#message_send').click(function(){
        _gaq.push(['_trackEvent', 'profile wall', 'action block submit', 'message send']);
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
                               $('#' + key).parent().after($('<div class="error-message">' + error + '</div>'));
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
             data: {folder: '', target_id: $('#file_rcpt').val()},
             onSubmit: function(file, ext, iframe){
                 _gaq.push(['_trackEvent', 'profile wall', 'action block submit', 'file upload']);
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
        $('#file_rcpt').change(function(){
            file_upload.setData({folder: '', target_id: $(this).val()});
        });

    }

    /* Create wiki actions.
     */
    $('#wiki_create_send').click(function(){
        _gaq.push(['_trackEvent', 'profile wall', 'action block submit', 'wiki create']);
        create_wiki_url = $("#create-wiki-url").val();
        form = $(this).closest('form');

        for (instance in CKEDITOR.instances)
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
                               $('#' + key).parent().after($('<div class="error-message">'+error+'</div>'));
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

<%def name="send_message_block(msg_recipients)">
  <div id="send_message_block" class="action-block">
    <a class="${not active and 'inactive' or ''}" name="send-message"></a>
    <form method="POST" action="${url(controller='wall', action='send_message')}" id="message_form">
      <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_message_js')}" />
      ${h.select('group_id', [], msg_recipients)}
      <div class="action-tease">${_("Write your topic")}</div>
      <input id="message_subject" type="text" name="subject" class="tease-element" />
      <textarea name="message"></textarea>
      ${h.input_submit(_('Send'), id="message_send", class_='dark inline action-button')}
      <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
</%def>

<%def name="upload_file_block(file_recipients)">
  <div id="upload_file_block" class="action-block">
    <a class="${not active and 'inactive' or ''}" name="upload-file"></a>
    <form id="file_form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js', qualified=True)}" />
      ${h.select('file_rcpt', [], file_recipients)}
      ${h.input_submit(_('Upload file'), id="file_upload_submit", class_='dark inline action-button')}
      <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
  <div id="upload-failed-error-message" class="error-message action-reply">${_('File upload failed.')}</div>
</%def>

<%def name="create_wiki_block(wiki_recipients)">
  <div id="create_wiki_block" class="action-block">
    <a class="${not active and 'inactive' or ''}" name="create-wiki"></a>
    <form method="POST" action="${url(controller='wall', action='create_wiki')}" id="wiki_form">
      <input id="create-wiki-url" type="hidden" value="${url(controller='wall', action='create_wiki_js')}" />
      ${h.select('rcpt_wiki', [], wiki_recipients)}
      <div class="action-tease">${_("Write note title here")}</div>
      <input id="page_title" type="text" name="page_title" class="tease-element" />
      ${h.input_wysiwyg('page_content', '')}
      ${h.input_submit(_('Save'), id="wiki_create_send", class_='dark inline action-button')}
      <a class="cancel-button" href="#cancel">${_("Cancel")}</a>
    </form>
  </div>
</%def>


<%def name="action_block(msg_recipients, file_recipients, wiki_recipients)">
  <%
  show_messages = True
  show_files = bool(len(file_recipients))
  show_wiki = bool(len(wiki_recipients))
  %>
  <%actions:action_block>
    <%def name="links()">
      <a class="action ${'active' if show_messages else 'inactive'}" id="send_message" href="#send-message">${_('Group message')}</a>
      %if not show_files:
      ${tooltip(_('You need to be a member of a group or have subjects that you are studying to be able to quickly upload files.'))}
      %endif
      <a class="action ${'active' if show_files else 'inactive'}" id="upload_file" href="#upload-file">${_('File')}</a>
      %if not show_wiki:
      ${tooltip(_('You or your group need to have subjects that you are studying to be able to quickly create wiki notes in them.'))}
      %endif
      <a class="action ${'active' if show_wiki else 'inactive'}" id="create_wiki" href="#create-wiki">${_('Wiki note')}</a>
    </%def>

    %if show_messages:
      ${self.send_message_block(msg_recipients)}
    %endif
    %if show_files:
      ${self.upload_file_block(file_recipients)}
    %endif
    %if show_wiki:
      ${self.create_wiki_block(wiki_recipients)}
    %endif
  </%actions:action_block>
</%def>
