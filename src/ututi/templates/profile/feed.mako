<%inherit file="/profile/base.mako" />
<%namespace name="wall" file="/sections/wall_snippets.mako" import="head_tags"/>
<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
  ${wall.head_tags()}
  <script type="text/javascript">
    function reload_wall() {
      $('#wall').load("${url(controller='profile', action='feed_js')}");
    };
  </script>
</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<%self:rounded_block id="dashboard_actions">
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
</%self:rounded_block>

<div id="dashboard_action_blocks">
<%self:rounded_block id="send_message_block" class_="dashboard_action_block" style="display: none;">
  <form method="POST" action="${url(controller='profile', action='send_message')}" id="message_form">
    <input type="hidden" name="rcpt_id" id="rcpt_id" value=""/>
    ${h.input_line('rcpt', _('Group or user:'), id='rcpt')}
    <div class="formField" style="display: none;">
      <label for="default_tab">
        <span class="labelText">${_('Category')}</span>
        ${h.select("category_id", None, [], id='category_id')}
      </label>
    </div>
    ${h.input_line('subject', _('Subject:'), id="message_subject")}
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
</%self:rounded_block>

<%self:rounded_block id="upload_file_block" class_="dashboard_action_block" style="display: none;">
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
</%self:rounded_block>

<%self:rounded_block id="create_wiki_block" class_="dashboard_action_block" style="display: none;">
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
</%self:rounded_block>

${h.javascript_link('/javascript/ckeditor/ckeditor.js')|n}
<script type="text/javascript">
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

<div id='wall'>
  <div class="tip">
    ${_('This is a list of all the recent events in the subjects you are watching and the groups you belong to.')}
    <a href="${url(controller='profile', action='wall_settings')}">${_('Edit shown updates.')}</a>
  </div>

  %if c.events:
    % for event in c.events:
      ${event.snippet()}
    % endfor
  %else:
  <%self:rounded_block id="empty_wall_block">
    <%
        if c.user.location is None:
            groups_list_link = '/search?obj_type=group'
            subjects_list_link = '/search?obj_type=subject'
        else:
            groups_list_link = c.user.location.url(action='groups')
            subjects_list_link =  c.user.location.url(action='subjects')

    %>
    ${_('This is the Ututi wall. Here you will find notifications about '\
        'things that concern you such as changes in your groups and the '\
        'subjects you are watching. Start by <a href="%(create_group_link)s">creating</a> '\
        'or <a href="%(groups_list_link)s">joining</a> a group and watching '\
        'some <a href="%(subjects_list_link)s">subjects</a>.')\
        % dict(
            create_group_link = url(controller = 'group', action = 'group_type'),
            groups_list_link = groups_list_link,
            subjects_list_link = subjects_list_link) | n}
  </%self:rounded_block>


  %endif
</div>
