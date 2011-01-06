<%inherit file="/profile/base.mako" />
<%namespace name="b" file="/prebase.mako" import="rounded_block"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip" />

<%def name="css()">
/* THE NEW WALL STYLE
 */

.wall {}

    .wall a#settings-link {
        font-size: 11px;        /* title and settings link next to each other */
        float: right;
    }

    .wall .wall-entry {
        border-bottom: 1px solid #ddd;
        color: #4d4d4d;
    }

        .wall .wall-entry .event-heading {
            font-size: 11px;
            padding: 5px 5px 5px 20px;
            background: url("/images/details/icon_event.png") no-repeat left center;
        }

            .wall .wall-entry .event-heading .hide-button {
                float: right;
                display: none;
            }

            .wall .wall-entry .event-heading:hover .hide-button {
                display: block;
            }


            /* Custom event icons:
             */

            .wall .wall-entry.type-member-joined .event-heading,
            .wall .wall-entry.type-group-created .event-heading {
                background-image: url("/img/icons/icon-group-tiny.png");
            }

            .wall .wall-entry.type-subject-created .event-heading {
                background-image: url("/img/icons/icon-subject-tiny.png");
            }

            .wall .wall-entry.type-private-message-sent .event-heading {
                background-image: url("/img/icons/icon-post-tiny.png");
            }

        .wall .wall-entry .event-time {
            color: #888;
            font-size: 11px;
            padding-left: 15px;
            background: url("/img/icons/icon_time.png") no-repeat left center;
        }

            .wall .wall-entry .event-heading .event-time {
                margin-left: 15px;
            }

        .wall .wall-entry .thread {
            width: 100%;
            overflow: auto; /* this clears the floats */
        }

            .wall .wall-entry .thread .logo {
                float: left;
            }

            .wall .wall-entry .thread .content {
                padding-left: 60px;
            }

                .wall .wall-entry .thread .reply .content,
                .wall .wall-entry .thread .reply-form-container .content {
                    padding-left: 40px;
                }

                .wall .wall-entry .thread .content .closing {
                    margin: 10px 0px;
                    font-size: 11px;
                }

                    .wall .wall-entry .thread .content .reply .closing {
                        margin: 5px 0px 0px 0px;
                    }

                    .wall .wall-entry .thread .content .reply .reply-author {
                        color: #d45500; /* Ututi orange */
                        margin-right: 5px;
                    }

            .wall .wall-entry .actions {
                margin-left: 5px;
            }

                .wall .wall-entry .actions a {
                    color: #668000;
                }

            .wall .wall-entry .reply {
                background-color: #f6f6f6;
                padding: 10px;
                margin-bottom: 3px;
            }

            .wall .wall-entry .reply-form-container {
                padding: 10px;
                margin-bottom: 5px;
            }

                .wall .wall-entry .reply-form-container .cancel-button {
                    font-size: 11px;
                    margin-left: 5px;
                }

                .wall .wall-entry .reply-form-container textarea {
                    border: 1px solid #ddd;
                    margin-bottom: 5px;
                    padding: 3px;
                    border-radius: 3px;
                    -moz-border-radius: 3px;
                    -webkit-border-radius: 3px;
                }

      
</%def>

<%def name="send_message_block(msg_recipients)">
  <%b:rounded_block id="send_message_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="send-message"></a>
    <form method="POST" action="${url(controller='profile', action='send_message')}" id="message_form" class="inelement-form">
      <input id="message-rcpt-url" type="hidden" value="${url(controller='profile', action='message_rcpt_js')}" />
      <input id="message-send-url" type="hidden" value="${url(controller='profile', action='send_message_js')}" />
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
  </%b:rounded_block>
</%def>

<%def name="upload_file_block(file_recipients)">
  <%b:rounded_block id="upload_file_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="upload-file"></a>
    <form id="file_form" class="inelement-form">
      <input id="file-upload-url" type="hidden" value="${url(controller='profile', action='upload_file_js')}" />
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
  </%b:rounded_block>
  <div id="upload-failed-error-message" class="action-reply">${_('File upload failed.')}</div>
</%def>

<%def name="create_wiki_block(wiki_recipients)">
  <%b:rounded_block id="create_wiki_block" class_="dashboard_action_block">
    <a class="${not active and 'inactive' or ''}" name="create-wiki"></a>
    <form method="POST" action="${url(controller='profile', action='create_wiki')}" id="wiki_form" class="inelement-form">
      <input id="create-wiki-url" type="hidden" value="${url(controller='profile', action='create_wiki_js')}" />
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
  </%b:rounded_block>
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

  <%b:rounded_block id="dashboard_actions">
  <div class="tip">${_('Share with others')}</div>
  <a class="action ${not show_messages and 'inactive' or ''}" id="send_message" href="#send-message">${_('send a message')}</a>
  %if not show_files:
  ${tooltip(_('You need to be a member of a group or have subjects that you are studying to be able to quickly upload files.'))}
  %endif
  <a class="action ${not show_files and 'inactive' or ''}" id="upload_file" href="#upload-file">${_('upload a file')}</a>
  %if not show_wiki:
  ${tooltip(_('You or your group need to have subjects that you are studying to be able to quickly create wiki notes in them.'))}
  %endif
  <a class="action ${not show_wiki and 'inactive' or ''}" id="create_wiki" href="#create-wiki">${_('create a wiki page')}</a>
  </%b:rounded_block>

  ${self.wall_reload_url()}

  <div id="dashboard_action_blocks">
    ${self.send_message_block(msg_recipients)}
    ${self.upload_file_block(file_recipients)}
    ${self.create_wiki_block(wiki_recipients)}
  </div>
</%def>

<%def name="body_class()">wall</%def>

<%def name="pagetitle()">
  ${_("What's new?")}
</%def>

<%def name="head_tags()">
  ${h.javascript_link('/javascript/dashboard.js')}
  ${h.javascript_link('/javascript/ckeditor/ckeditor.js')}
</%def>

<a id="settings-link" href="${url(controller='profile', action='wall_settings')}">${_('Wall settings')}</a>

${dashboard(None, [], [])}

%for event in c.events:
  ${event.wall_entry()}
%endfor
