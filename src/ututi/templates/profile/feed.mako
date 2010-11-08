<%inherit file="/profile/base.mako" />
<%namespace name="wall" file="/sections/wall_snippets.mako" import="head_tags"/>
<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
  ${wall.head_tags()}
</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<%self:rounded_block id="dashboard_actions">
<div class="tip">${_('Share with others')}</div>
<a class="action" id="send_message" href="#">${_('send a message')}</a>
<a class="action" id="upload_file" href="#">${_('upload a files')}</a>
<a class="action" id="create_wiki" href="#">${_('create a wiki page')}</a>
<script type="text/javascript">
  $('#dashboard_actions a.action').toggle(function(){
    id = $(this).attr('id');
    $('#'+id+'_block').slideDown(300);
    return false;
  },
  function() {
    id = $(this).attr('id');
    $('#'+id+'_block').slideUp(300);
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
<script type="text/javascript">
$(function(){
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
                           $('#dashboard_action_blocks').after('<div class="action-reply">'+"${_('Message sent.')}"+'</div>');
                       }
                   },
                   "json");
        }
        return false;
    });
});
</script>
</%self:rounded_block>
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
  ${_('Sorry, nothing new at the moment.')}
%endif
</div>
