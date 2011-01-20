<%doc>
  Wall actionblock for the user's wall.
</%doc>

<%namespace name="actions" file="/sections/wall_actionblock.mako" import="head_tags, action_block" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip" />

<%def name="head_tags()">
  ${actions.head_tags()}
  <script type="text/javascript">
  $(function(){
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
                } else {
                  self.options[0].selected = true;
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
    if ($("#upload_file_block").length > 0) {

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
                 iframe['progress_indicator'].remove();
                 if (response != 'UPLOAD_FAILED') {
                     $('#file_upload_form').find('input, textarea').val('');
                     $('#upload_file').click();
                     $('#upload_file_block').removeClass('upload-failed');
                     reload_wall();
                 } else {
                     $('#upload-failed-error-message').fadeIn(500);
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
  </script>
</%def>

<%def name="send_message_block(msg_recipients)">
  <%base:rounded_block id="send_message_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="send-message"></a>
    <form method="POST" action="${url(controller='wall', action='send_message')}" id="message_form" class="inelement-form">
      <input id="message-rcpt-url" type="hidden" value="${url(controller='profile', action='message_rcpt_js')}" />
      <input id="message-send-url" type="hidden" value="${url(controller='wall', action='send_message_js')}" />
      <input type="hidden" name="rcpt_id" id="rcpt_id" value=""/>
      ${h.input_line('rcpt', _('Group or user:'), id='rcpt')}
      <div class="formField" style="display: none;">
        <label for="default_tab">
          <span class="labelText">${_('Category')}</span>
          ${h.select("category_id", None, [], id='category_id')}
        </label>
      </div>
      ${h.input_line('subject', _('Message subject:'), id="message_subject")}
      <div class="formArea">
        <label>
          <textarea name="message" id="message" rows="5" rows="50"></textarea>
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Send'), id="message_send")}
      </div>
      <br class="clearLeft" />
    </form>
  </%base:rounded_block>
</%def>

<%def name="upload_file_block(file_recipients)">
  <%base:rounded_block id="upload_file_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='wall', action='upload_file_js')}" />
      <div class="formField">
        <label for="file_rcpt_id">
          <span class="labelText">${_('Group or subject:')}</span>
          <span class="textField">
            ${h.select('file_rcpt_id', None, file_recipients)}
          </span>
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Upload file'), id="file_upload_submit")}
      </div>
      <br class="clearLeft" />
    </form>
  </%base:rounded_block>
  <div id="upload-failed-error-message" class="action-reply">${_('File upload failed.')}</div>
</%def>

<%def name="create_wiki_block(wiki_recipients)">
  <%base:rounded_block id="create_wiki_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="create-wiki"></a>
    <form method="POST" action="${url(controller='wall', action='create_wiki')}" id="wiki_form" class="inelement-form">
      <input id="create-wiki-url" type="hidden" value="${url(controller='wall', action='create_wiki_js')}" />
      <div class="formField">
        <label for="wiki_rcpt_id">
          <span class="labelText">${_('Subject:')}</span>
          <span class="textField">
            ${h.select('wiki_rcpt_id', None, wiki_recipients)}
          </span>
        </label>
      </div>
      ${h.input_line('page_title', _('Title'), id='page_title')}
      <div style="clear: right;">
        ${h.input_wysiwyg('page_content', '')}
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Save'), id="wiki_create_send")}
      </div>
      <br class="clearLeft" />
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
      <a class="action ${not show_messages and 'inactive' or ''}" id="send_message" href="#send-message">${_('send a message')}</a>
      %if not show_files:
      ${tooltip(_('You need to be a member of a group or have subjects that you are studying to be able to quickly upload files.'))}
      %endif
      <a class="action ${not show_files and 'inactive' or ''}" id="upload_file" href="#upload-file">${_('upload a file')}</a>
      %if not show_wiki:
      ${tooltip(_('You or your group need to have subjects that you are studying to be able to quickly create wiki notes in them.'))}
      %endif
      <a class="action ${not show_wiki and 'inactive' or ''}" id="create_wiki" href="#create-wiki">${_('create a wiki page')}</a>
    </%def>

    ${self.send_message_block(msg_recipients)}
    ${self.upload_file_block(file_recipients)}
    ${self.create_wiki_block(wiki_recipients)}

  </%actions:action_block>
</%def>
