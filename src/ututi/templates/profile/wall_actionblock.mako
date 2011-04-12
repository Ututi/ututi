<%doc>
  Wall actionblock for the user's wall.
</%doc>

<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace name="dropdown" file="/widgets/dropdown.mako" import="dropdown, head_tags"/>
<%namespace file="/elements.mako" import="tooltip" />

<%def name="css()">
#rcpt_user-field { display: none; }
</%def>

<%def name="head_tags()">
  ${actions.head_tags()}
  ${dropdown.head_tags()}
  <script type="text/javascript">
  $(function(){
    /* Send message actions.
     */
    $('#rcpt_group .action a').click(function(){
      if ($(this).attr('id') == 'select-pm') {
        $('#rcpt_user-field').show();
      } else {
        $('#rcpt_user-field').hide();
      }
    });
    message_rcpt_url = $("#message-rcpt-url").val();
    $('#rcpt_user').autocomplete({
        source: function(request, response) {
            $.getJSON(message_rcpt_url,
                      request, function(data, status, xhr) {
                          response(data.data);
                      });
        },
        minLength: 2,
        select: function(event, ui) {
            $(this).closest('form').find('#rcpt_user_id').val(ui.item.id);
        }
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
             data: {folder: '', target_id: $('#file_rcpt-select').val()},
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
        $('#file_rcpt-select').change(function(){
            file_upload.setData({folder: '', target_id: $(this).val()});
        });

    }

    /* Create wiki actions.
     */
    $('#wiki_create_send').click(function(){
        _gaq.push(['_trackEvent', 'profile wall', 'action block submit', 'wiki create']);
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
                           $('#wiki_form').find('input[type="text"], textarea').val('');
                           for (instance in CKEDITOR.instances)
                               CKEDITOR.instances[instance].setData('');
                           $('#create_wiki').click();
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
  <%base:rounded_block id="send_message_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="send-message"></a>
    <form method="POST" action="${url(controller='wall', action='send_message')}" id="message_form" class="inelement-form">
      <input id="message-rcpt-url" type="hidden" value="${url(controller='wall', action='message_rcpt_js')}" />
      <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_message_js')}" />

      ${dropdown.dropdown('rcpt_group', _('Write a message to:'), msg_recipients)}
      <input type="hidden" name="rcpt_user_id" id="rcpt_user_id" value=""/>
      ${h.input_line('rcpt_user', _('User:'), id='rcpt_user', class_='wide-input')}
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

<%def name="upload_file_block(file_recipients)">
  <%base:rounded_block id="upload_file_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js', qualified=True)}" />
      ${dropdown.dropdown('file_rcpt', _('Upload a file to:'), file_recipients)}
      <br class="clearBoth" />
      <div class="formSubmit">
        ${h.input_submit(_('Upload file'), id="file_upload_submit")}
      </div>
    </form>
  </%base:rounded_block>
  <div id="upload-failed-error-message" class="action-reply">${_('File upload failed.')}</div>
</%def>

<%def name="create_wiki_block(wiki_recipients)">
  <%base:rounded_block id="create_wiki_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="create-wiki"></a>
    <form method="POST" action="${url(controller='wall', action='create_wiki')}" id="wiki_form" class="inelement-form">
      <input id="create-wiki-url" type="hidden" value="${url(controller='wall', action='create_wiki_js')}" />
      ${dropdown.dropdown('rcpt_wiki', _('Create a note on:'), wiki_recipients)}
      ${h.input_line('page_title', _('Title'), id='page_title', class_='wide-input')}
      <div style="clear: right;">
        ${h.input_wysiwyg('page_content', '')}
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Save'), id="wiki_create_send")}
      </div>
    </form>
  </%base:rounded_block>
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
