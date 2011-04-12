<%doc>
  Wall dashboard snippets, works together with dashboard.js.
</%doc>

<%namespace name="base" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/elements.mako" import="tooltip" />

<%def name="head_tags()">
  ${h.javascript_link('/javascript/dashboard.js')}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')}
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

<%def name="wall_reload_url()">
  ## Hidden action url, used to ajax-refresh the wall.
  <input id="wall-reload-url" type="hidden" value="${url(controller='profile', action='feed_js')}" />
</%def>

<%def name="dashboard(msg_recipients, file_recipients, wiki_recipients)">

  <%
  show_messages = True
  show_files = bool(len(file_recipients))
  show_wiki = bool(len(wiki_recipients))
  %>

  <div id="dashboard_actions">
  <div class="tip">${_('Share with others')}</div>
  <a class="action ${'active' if show_messages else 'inactive'}" id="send_message" href="#send-message">${_('send a message')}</a>
  %if not show_files:
  ${tooltip(_('You need to be a member of a group or have subjects that you are studying to be able to quickly upload files.'))}
  %endif
  <a class="action ${'active' if show_files else 'inactive'}" id="upload_file" href="#upload-file">${_('upload a file')}</a>
  %if not show_wiki:
  ${tooltip(_('You or your group need to have subjects that you are studying to be able to quickly create wiki notes in them.'))}
  %endif
  <a class="action ${'active' if show_wiki else 'inactive'}" id="create_wiki" href="#create-wiki">${_('create a wiki page')}</a>
  </div>

  ${self.wall_reload_url()}

  <div id="dashboard_action_blocks">
    ${self.send_message_block(msg_recipients)}
    ${self.upload_file_block(file_recipients)}
    ${self.create_wiki_block(wiki_recipients)}
  </div>

</%def>
