<%inherit file="/sections/wall_dashboard.mako" />
<%namespace name="base" file="/prebase.mako" import="rounded_block"/>

<%def name="send_message_block(msg_recipient)">
  <% group_id, group_title, forum_categories = msg_recipient %>
  <%base:rounded_block id="send_message_block" class_="dashboard_action_block">
    <a name="send-message"></a>
    <form method="POST" action="${url(controller='group', action='send_message')}" id="message_form">
      <input id="message-send-url" type="hidden" value="${url(controller='group', action='send_message_js')}" />
      <input type="hidden" name="rcpt_id" id="rcpt_id" value="${group_id}"/>
      <input type="hidden" name="rcpt" id="rcpt_id" value="${group_title}"/>
      %if forum_categories:
      <div class="formField">
        <label for="default_tab">
          <span class="labelText">${_('Category')}</span>
          ${h.select("category_id", None, forum_categories, id='category_id')}
        </label>
      </div>
      %endif
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
    <a name="upload-file"></a>
    <form id="file_form">
      <input id="file-upload-url" type="hidden" value="${url(controller='group', action='upload_file_js')}" />
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
      <div id="upload-failed-error-message" class="action-reply">${_('File upload failed.')}</div>
    </form>
  </%base:rounded_block>
</%def>

<%def name="create_wiki_block(wiki_recipients)">
  <%base:rounded_block id="create_wiki_block" class_="dashboard_action_block">
    <a name="create-wiki"></a>
    <form method="POST" action="${url(controller='group', action='create_wiki')}" id="wiki_form">
      <input id="create-wiki-url" type="hidden" value="${url(controller='group', action='create_wiki_js')}" />
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

<%def name="wall_reload_url()">
  ## Hidden action url, used to ajax-refresh the wall.
  <input id="wall-reload-url" type="hidden" value="${url(controller='group', action='feed_js', id=c.group.group_id)}" />
</%def>
