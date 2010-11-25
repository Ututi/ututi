<%namespace name="base" file="/prebase.mako" import="rounded_block"/>

<%def name="dashboard()">

  <%base:rounded_block id="dashboard_actions">
  <div class="tip">${_('Share with others')}</div>
  <a class="action" id="send_message" href="#">${_('send a message')}</a>
  <a class="action" id="upload_file" href="#">${_('upload a file')}</a>
  <a class="action" id="create_wiki" href="#">${_('create a wiki page')}</a>
  <script type="text/javascript">
    $('#dashboard_actions a.action').click(function(){
        id = $(this).attr('id');
        if ($(this).hasClass('open')) {
            $(this).removeClass('open');
            $('#'+id+'_block').slideUp(300);
        } else {
            $('#dashboard_actions a.open').each(function(){
                $(this).removeClass('open');
                cls_id = $(this).attr('id');
                $('#'+cls_id+'_block').slideUp(300);
            });
            $(this).addClass('open');
            $('#'+id+'_block').slideDown(300);
        }
        return false;
    });
  </script>
  </%base:rounded_block>

  <div id="dashboard_action_blocks">
  <%base:rounded_block id="send_message_block" class_="dashboard_action_block" style="display: none;">
    <form method="POST" action="${url(controller='profile', action='send_message')}" id="message_form">
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

  <%base:rounded_block id="upload_file_block" class_="dashboard_action_block" style="display: none;">
    <form id="file_form">
      <div class="formField">
        <label for="file_rcpt_id">
          <span class="labelText">${_('Group or subject:')}</span>
          <span class="textField">
            ${h.select('file_rcpt_id', None, c.file_recipients)}
          </span>
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Upload file'), id="file_upload_submit")}
      </div>
      <br class="clearLeft" />
    </form>
  </%base:rounded_block>

  <%base:rounded_block id="create_wiki_block" class_="dashboard_action_block" style="display: none;">
    <form method="POST" action="${url(controller='profile', action='create_wiki')}" id="wiki_form">
      <div class="formField">
        <label for="wiki_rcpt_id">
          <span class="labelText">${_('Subject:')}</span>
          <span class="textField">
            ${h.select('wiki_rcpt_id', None, c.wiki_recipients)}
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

  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')}

  <script type="text/javascript">

  function reload_wall() {
    $('#wall').load("${url(controller='profile', action='feed_js')}");
  };

  $(function(){
      /* message block */
      $( "#rcpt" ).autocomplete({
          source: function(request, response) {
              $.getJSON("${url(controller='profile', action='message_rcpt_js')}",
                        request, function( data, status, xhr ) {
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
      $("#message_send").click(function(){
          form = $(this).closest('form');

          subject = $('#message_subject', form).val();
          message = $('#message', form).val();

          if ((subject != '') && (message != '')) {
              $.post("${url(controller='profile', action='send_message_js')}",
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
                             //$('#dashboard_action_blocks').after('<div class="action-reply">'+"${_('Message sent.')}"+'</div>');
                         }
                     },
                     "json");
          }
          return false;
      });
      /* file block */
      $('#file_upload_submit').click(function(){return false;});
      var file_upload = new AjaxUpload($('#file_upload_submit'),
          {action: "${url(controller='profile', action='upload_file_js')}",
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
                   reload_wall();
                   //$('#dashboard_action_blocks').after('<div class="action-reply">'+"${_('File uploaded.')}"+'</div>');
               } else {
                   $('#dashboard_action_blocks').after('<div class="action-reply">'+"${_('File upload failed.')}"+'</div>');
               }
               window.clearInterval(iframe['interval']);
           }
          });
      $( "#file_rcpt_id" ).change(function(){
          file_upload.setData({folder: '', target_id: $(this).val()});
      });
      /* wiki mode */
      $('#wiki_create_send').click(function(){
          form = $(this).closest('form');

          for ( instance in CKEDITOR.instances )
              CKEDITOR.instances[instance].updateElement();


          title = $('#page_title', form).val();
          content = $('#page_content', form).val();

          if ((title != '') && (content != '')) {
              $.post("${url(controller='profile', action='create_wiki_js')}",
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
                             //$('#dashboard_action_blocks').after('<div class="action-reply">'+"${_('Wiki page created\.')}"+'</div>');
                         }
                     },
                     "json");
          }
          return false;
      });

  });
  </script>
  </div>

</%def>
