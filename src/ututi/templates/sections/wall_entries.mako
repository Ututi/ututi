<%namespace name="moderation" file="/mailinglist/administration.mako" />
<%namespace name="sms" file="/widgets/sms.mako" />

<%def name="head_tags()">
  ${h.javascript_link('/javascript/wall.js')}
  ${h.javascript_link('/javascript/jquery.jtruncate.pack.js')}
  ${h.javascript_link('/javascript/moderation.js')}
  <script type="text/javascript">
  $(document).ready(function() {
      /* Truncate texts. */
      $('span.truncated').jTruncate({
          length: 150,
          minTrail: 50,
          moreText: "${_('more')}",
          lessText: "${_('less')}",
          moreAni: 300
          ## leave lessAni empty, to avoid jQuery show/hide quirks!
          ## (after first hide it would the show element as inline-block,
          ##  (instead of inline) affeting layout)
      });
  });
  </script>
  ${h.stylesheet_link('/widgets.css')}
</%def>

<%def name="wall_entry(event)">
<div class="wall-entry ${caller.classes()} type_${event.event_type}" id="wall-event-${event.id}">
  <div class="event-heading">
    ${caller.heading()}
    <span class="event-time">
      ${h.when(event.created)}
    </span>
    %if c.user is not None:
    <div class="hide-button-container">
      <form method="POST" action="${url(controller='profile', action='hide_event')}">
        <div>
          <input class="event-type" name="event_type" type="hidden" value="${event.event_type}" />
          <input class="hide-button" type="image" src="/images/details/icon_delete.png" title="${_('Ignore events like this')}" />
        </div>
      </form>
    </div>
    %endif
  </div>
  <div class="event-body">
    ${caller.body()}
  </div>
</div>
</%def>

<%def name="thread_reply(author, message, created, attachments=None)">
  <div class="reply">
    <div class="logo">
      <img src="${author.url(action='logo', width=30)}" />
    </div>
    <div class="content">
      <span class="reply-author">${h.object_link(author)}:</span>
      <span class="truncated">${h.nl2br(message)}</span>
      %if attachments:
      <ul class="file-list">
        %for file in attachments:
        <li><a href="${file.url()}">${file.title}</a></li>
        %endfor
      </ul>
      %endif
      <div class="closing">
        <span class="event-time">${h.when(created)}</span>
        <span class="actions">
          <a href="#reply" class="action-block-link">${_('Reply')}</a>
        </span>
      </div>
    </div>
  </div>
</%def>

<%def name="event_conversation(event, head_message=True)">
  <%doc>
    Renders message thread and reply action box.
    Event must implement MessagingEventMixin.

    If head_message is True, then the first (original) message
    is displayed differently, with bigger logo and etc.
  </%doc>
  <%
    messages = event.message_list()
    if head_message:
      original = messages.pop(0)
  %>
  <div class="thread">
    %if head_message:
    <div class="logo">
      <img src="${original['author'].url(action='logo', width=50)}" />
    </div>
    %endif
    <div class="content">
      %if head_message:
        <span class="truncated">${h.nl2br(original['message'])}</span>
        %if 'attachments' in original:
        <ul class="file-list">
          %for file in original['attachments']:
          <li><a href="${file.url()}">${file.title}</a></li>
          %endfor
        </ul>
        %endif
        <div class="closing">
          <span class="event-time">${h.when(original['created'])}</span>
          <span class="actions">
            <a href="#reply" class="action-block-link">${_('Reply')}</a>
          </span>
        </div>
      %endif
      <div class="replies">
        %if len(messages) > 3:
          <%
          hidden = messages[:-3]
          messages = messages[-3:]
          %>
          <div class="click2show hidden-messages">
            <div class="hide">
              <a class="click">
                ${_("Show older messages (%(message_count)s)") % dict(message_count=len(hidden))}
              </a>
            </div>
            <div class="show">
              %for msg in hidden:
                ${thread_reply(**msg)}
              %endfor
            </div>
          </div>
        %endif
        %for msg in messages:
          ${thread_reply(**msg)}
        %endfor
      </div>
      <div class="reply-form-container action-block">
        <div class="logo">
          <img src="${url(controller='user', action='logo', id=c.user.id, width=30)}" />
        </div>
        <div class="content">
          <form name="reply-form" method="POST" action="${event.reply_action()}">
            <textarea rows="3" cols="50" class="reply-text" name="message"></textarea>
            <div>
              ${h.input_submit(_('Send reply'), class_='btn reply-button')}
              <a class="action-block-cancel" href="#cancel-reply">${_("Cancel")}</a>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</%def>

<%def name="file_description(file)">
  <div class="file-description">
    <div class="title">
      %if file.isDeleted():
        ${file.filename}
      %else:
        ${h.object_link(file)}
      %endif
    </div>
    <span class="event-time">${h.when(file.created_on)}</span>
    <span class="actions">
      <a href="#reply" class="action-block-link">
        ## TRANSLATORS: translate this as a verb 'Comment'
        ${_('comment_on_wall')}
      </a>
    </span>
  </div>
</%def>

<%def name="page_description(page)">
  <div class="page-description">
    <div class="title">
      %if page.isDeleted():
        ${page.title}
      %else:
        ${h.object_link(page)}
      %endif
    </div>
    <span class="event-time">${h.when(page.created_on)}</span>
    <span class="actions">
      <a href="#reply" class="action-block-link">
        ## TRANSLATORS: translate this as a verb 'Comment'
        ${_('comment_on_wall')}
      </a>
    </span>
  </div>
</%def>

<%def name="file_uploaded_subject(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have uploaded a new file in the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.file.parent)) | n}
      %else:
        ${_("%(user_link)s has uploaded a new file in the subject %(subject_link)s") % \
           dict(user_link=h.object_link(event.user),
                subject_link=h.object_link(event.file.parent)) | n}
      %endif
    </%def>
    <%self:file_description file="${event.file}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </%self:wall_entry>
</%def>

<%def name="folder_created_subject(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have created a new folder %(folder_name)s in the subject %(subject_link)s") % \
           dict(folder_name=event.file.folder,
                subject_link=h.object_link(event.file.parent)) | n}
      %else:
        ${_("%(user_link)s has created a new folder %(folder_name)s in the subject %(subject_link)s") % \
           dict(user_link=h.object_link(event.user),
                folder_name=event.file.folder,
                subject_link=h.object_link(event.file.parent)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="file_uploaded_group(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have uploaded a new file in the group %(group_link)s") % \
           dict(group_link=h.object_link(event.file.parent)) | n}
      %else:
        ${_("%(user_link)s has uploaded a new file in the group %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                group_link=h.object_link(event.file.parent)) | n}
      %endif
    </%def>
    <%self:file_description file="${event.file}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </%self:wall_entry>
</%def>

<%def name="folder_created_group(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have created a new folder %(folder_name)s in the group %(group_link)s") % \
           dict(folder_name=event.file.folder,
                group_link=h.object_link(event.file.parent)) | n}
      %else:
        ${_("%(user_link)s has created a new folder %(folder_name)s in the group %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                folder_name=event.file.folder,
                group_link=h.object_link(event.file.parent)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="subject_modified(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have edited the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.context)) | n}
      %else:
        ${_("%(user_link)s has edited the subject %(subject_link)s") % \
           dict(user_link=h.object_link(event.user),
                subject_link=h.object_link(event.context)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="subject_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have created the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.context)) | n}
      %else:
        ${_("%(user_link)s has created the subject %(subject_link)s") % \
           dict(user_link=h.object_link(event.user),
                subject_link=h.object_link(event.context)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="group_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have created the group %(group_link)s") % \
           dict(group_link=h.object_link(event.context)) | n}
      %else:
        ${_("%(user_link)s has created the group %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                group_link=h.object_link(event.context)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="mailinglistpost_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">message-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.message.author:
        ${_("You have posted a new message %(message_link)s to the group %(group_link)s") % \
           dict(group_link=h.object_link(event.context),
                message_link=h.object_link(event.message)) | n}
      %else:
        ${_("%(user_link)s has posted a new message %(message_link)s to the group %(group_link)s") % \
           dict(user_link=h.object_link(event.message.author_or_anonymous),
                group_link=h.object_link(event.context),
                message_link=h.object_link(event.message)) | n}
      %endif
    </%def>
    <%self:event_conversation event="${event}"/>
  </%self:wall_entry>
</%def>

<%def name="teachermessage_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">message-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
          ${_("You have sent a message to the group %(group_link)s") % \
             dict(group_link=h.object_link(event.context)) | n}
      %else:
          ${_("Teacher %(user_link)s has sent a message to the group %(group_link)s") % \
             dict(user_link=h.object_link(event.user),
                  group_link=h.object_link(event.context)) | n}
      %endif
    </%def>
    ## The following snippet is copied from event_conversation def.
    ## This is a temporary solution as teacher messages should be
    ## handled the same way as any other messages.
    <div class="thread">
      <div class="logo">
        <img src="${event.user.url(action='logo', width=50)}" />
      </div>
      <div class="content">
        <span class="truncated">${h.nl2br(event.data)}</span>
      </div>
    </div>
  </%self:wall_entry>
</%def>

<%def name="moderated_post_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">message-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.message.author:
        ${_("You have posted a new message %(message_link)s to the group's %(group_link)s moderation queue") % \
             dict(group_link=h.object_link(event.context),
                  message_link=h.object_link(event.message)) | n}
      %else:
        ${_("%(user_link)s has posted a new message %(message_link)s to the group's %(group_link)s moderation queue") % \
             dict(user_link=h.object_link(event.message.author_or_anonymous),
                  group_link=h.object_link(event.context),
                  message_link=h.object_link(event.message)) | n}
      %endif
    </%def>
    ## The following snippet is copied from event_conversation def.
    ## This markup should probably be shared but I don't know the
    ## best way to do that yet.
    <% msg = event.message %>
    <div class="thread">
      <div class="logo">
        <img src="${msg.author_or_anonymous.url(action='logo', width=50)}" />
      </div>
      <div class="content">
        <span class="truncated">${h.nl2br(event.message.body)}</span>
        %if msg.attachments:
        <ul class="file-list">
          %for file in msg.attachments:
          <li><a href="${file.url()}">${file.title}</a></li>
          %endfor
        </ul>
        %endif
        <div class="closing">
          ## XXX the msg.created was None at this point. Why is that so?
          <span class="event-time">${h.when(event.created)}</span>
          <span class="actions">
            <a href="#moderate" class="action-block-link">Moderate</a>
          </span>
        </div>
        <div class="action-block">
          <div class="content">
            ${moderation.listThreadsActions(msg)}
          </div>
        </div>
      </div>
    </div>
  </%self:wall_entry>
</%def>

<%def name="forumpost_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">message-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have posted a new message %(message_link)s in the forum %(group_link)s") % \
           dict(group_link=h.object_link(event.context),
                message_link=h.object_link(event.post)) | n}
      %else:
        ${_("%(user_link)s has posted a new message %(message_link)s in the forum %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                group_link=h.object_link(event.context),
                message_link=h.object_link(event.post)) | n}
      %endif
    </%def>
    <%self:event_conversation event="${event}"/>
  </%self:wall_entry>
</%def>

<%def name="sms_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">sms-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have sent an sms to the group %(group_link)s") % \
           dict(group_link=h.object_link(event.context)) | n}
      %else:
        ${_("%(user_link)s has sent an sms to the group %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                group_link=h.object_link(event.context)) | n}
      %endif
    </%def>
    <div class="thread">
      <div class="logo">
        <img src="${event.user.url(action='logo', width=50)}" />
      </div>
      <div class="content">
        <span class="truncated">${h.nl2br(event.sms_text())}</span>
        <div class="closing">
          <span class="event-time">${h.when(event.sms_created())}</span>
          <span class="actions">
            <a href="#moderate" class="action-block-link">${_('Reply')}</a>
          </span>
        </div>
        <div class="action-block">
          <div class="content">
            ${sms.sms_widget_tiny(c.user, event.context)}
          </div>
        </div>
      </div>
    </div>
  </%self:wall_entry>
</%def>

<%def name="privatemessage_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">message-event</%def>
    <%def name="heading()">
      <% msg = event.private_message %>
      %if c.user is not None and c.user == msg.recipient:
        ${_("%(user_link)s has sent you a private message \"%(msg_link)s\"") % \
           dict(user_link=h.object_link(msg.sender),
                msg_link=h.object_link(msg)) | n}
      %elif c.user is not None and c.user ==  msg.sender:
        ${_("You have sent %(user_link)s a private message \"%(msg_link)s\"") % \
           dict(user_link=h.object_link(msg.recipient),
                msg_link=h.object_link(msg)) | n}
      %else:
        ${_("%(sender_link)s has sent %(recipient_link)s a private message \"%(msg_link)s\"") % \
           dict(sender_link=h.object_link(msg.sender),
                recipient_link=h.object_link(msg.recipient),
                msg_link=h.object_link(msg)) | n}
      %endif
    </%def>
    <%self:event_conversation event="${event}"/>
  </%self:wall_entry>
</%def>

<%def name="groupmember_joined(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have joined the group %(group_link)s") % \
           dict(group_link=h.object_link(event.context)) | n}
      %else:
        ${_("%(user_link)s has joined the group %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                group_link=h.object_link(event.context)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupmember_left(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have left the group %(group_link)s") % \
           dict(group_link=h.object_link(event.context)) | n}
      %else:
        ${_("%(user_link)s has left the group %(group_link)s") % \
           dict(user_link=h.object_link(event.user),
                group_link=h.object_link(event.context)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupsubject_start(event)">
  <%self:wall_entry event="${event}">
    %if event.context in c.user.groups:
    <%def name="classes()">group-event</%def>
    %else:
    <%def name="classes()">subject-event</%def>
    %endif
    <%def name="heading()">
      ${_("The group %(group_link)s has started watching the subject %(subject_link)s") % \
         dict(subject_link=h.object_link(event.subject),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupsubject_stop(event)">
  <%self:wall_entry event="${event}">
    %if event.context in c.user.groups:
    <%def name="classes()">group-event</%def>
    %else:
    <%def name="classes()">subject-event</%def>
    %endif
    <%def name="heading()">
      ${_("The group %(group_link)s has stopped watching the subject %(subject_link)s") % \
         dict(subject_link=h.object_link(event.subject),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="page_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have created a page %(page_link)s in the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.context),
                page_link=h.object_link(event.page)) | n}
      %else:
        ${_("%(user_link)s has created a page %(page_link)s in the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.context),
                page_link=h.object_link(event.page),
                user_link=h.object_link(event.user)) | n}
      %endif
    </%def>
    <%self:page_description page="${event.page}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </%self:wall_entry>
</%def>

<%def name="page_modified(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user == event.user:
        ${_("You have modified a page %(page_link)s in the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.context),
                page_link=h.object_link(event.page)) | n}
      %else:
        ${_("%(user_link)s has modified a page %(page_link)s in the subject %(subject_link)s") % \
           dict(subject_link=h.object_link(event.context),
                page_link=h.object_link(event.page),
                user_link=h.object_link(event.user)) | n}
      %endif
    </%def>
    <%self:page_description page="${event.page}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </%self:wall_entry>
</%def>
