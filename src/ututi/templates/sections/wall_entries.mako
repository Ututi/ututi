<%def name="wall_entry(event)">
<div class="wall-entry type-${event.event_type.replace('_', '-')} ${caller.classes()}" id="wallevent-${event.id}">
  %if c.user is not None:
  <div class="hide-button">
    <form method="POST" action="${url(controller='profile', action='hide_event')}">
      <div>
        <input type="hidden" name="event_type" value="${event.event_type}" />
        <input type="image" src="/images/details/icon_delete.png" title="${_('Ignore events like this')}" />
      </div>
    </form>
  </div>
  %endif
  <div class="description">
    ${caller.description()}
    <span class="event-time">
      ${event.when()}
    </span>
  </div>
  %if hasattr(caller, 'content'):
  <div class="content">
    ${caller.content()}
  </div>
  %endif
</div>
</%def>

<%def name="file_uploaded_subject(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <div class="file_link">
        ${h.object_link(event.file)}
      </div>
    </%def>
    <%def name="description()">
      ${_("%(user_link)s has uploaded a new file in the subject %(subject_link)s.") % \
         dict(user_link=h.object_link(event.user),
              subject_link=h.object_link(event.file.parent)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="folder_created_subject(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has created a new folder %(folder_name)s in the subject %(subject_link)s.") % \
         dict(user_link=h.object_link(event.user),
              folder_name=event.file.folder,
              subject_link=h.object_link(event.file.parent)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="file_uploaded_group(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <div class="file_link">
        ${h.object_link(event.file)}
      </div>
    </%def>
    <%def name="description()">
      ${_("%(user_link)s has uploaded a new file in the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.file.parent)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="folder_created_group(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has created a new folder %(folder_name)s in the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              folder_name=event.file.folder,
              group_link=h.object_link(event.file.parent)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="subject_modified(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has edited the subject %(subject_link)s.") % \
         dict(user_link=h.object_link(event.user),
              subject_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="subject_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has created the subject %(subject_link)s.") % \
         dict(user_link=h.object_link(event.user),
              subject_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="group_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has created the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="mailinglistpost_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <span class="truncated">${h.email_with_replies(event.message.body, True)}</span>
    </%def>
    <%def name="action_link()">${_('Reply')}</%def>
    <%def name="action()">
      <%base:rounded_block>
      <form method="post" action="${url(controller='mailinglist', action='reply', thread_id=event.message.thread.id, id=event.context.group_id)}"
            id="mail_reply_form" class="wallForm">
        ${h.input_area('message', '', rows=2)}
        <div class="line">
          ${h.input_submit(_('Send reply'), class_='btn action_submit')}
        </div>
      </form>
      </%base:rounded_block>
    </%def>
    <%def name="description()">
      ${_("%(user_link)s has posted a new message %(message_link)s to the group %(group_link)s.") % \
         dict(user_link=event.link_to_author(),
              group_link=h.object_link(event.context),
              message_link=h.object_link(event.message)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="teachermessage_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
            <span class="truncated">${h.nl2br(event.data)}</span>
    </%def>
    <%def name="description()">
      ${_("Teacher %(user_link)s sent a message to the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="moderated_post_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <span class="truncated">${h.email_with_replies(event.message.body, True)}</span>
    </%def>
    <%def name="description()">
      ${_("%(user_link)s has posted a new message %(message_link)s to the group's %(group_link)s moderation queue.") % \
           dict(user_link=event.link_to_author(),
                group_link=h.object_link(event.context),
                message_link=h.object_link(event.message)) | n}
    </%def>
    <%def name="action_link()">${_('Moderate')}</%def>
    <%def name="action()">
      <%base:rounded_block>
      ${moderation.listThreadsActions(event.message)}
      </%base:rounded_block>
    </%def>
  </%self:wall_entry>
</%def>

<%def name="forumpost_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <span class="truncated">${h.nl2br(event.post.message)}</span>
    </%def>
    <%def name="action_link()">${_('Reply')}</%def>
    <%def name="action()">
      <%base:rounded_block>
      <form method="post" action="${url(controller='forum', action='reply', id=event.context.group_id, category_id=event.post.category_id, thread_id=event.post.thread_id)}"
            id="forum_reply_form" class="fullForm" enctype="multipart/form-data">
        ${h.input_area('message', '', rows=2)}
        <div class="line">
          ${h.input_submit(_('Send reply'), class_='btn action_submit')}
        </div>
      </form>
      </%base:rounded_block>
    </%def>
    <%def name="description()">
      ${_("%(user_link)s has posted a new message %(message_link)s in the forum %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.context),
              message_link=h.object_link(event.post)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="sms_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">${event.sms_text()}</%def>
    <%def name="action_link()">${_('Reply')}</%def>
    <%def name="action()">
      <%base:rounded_block>
      ${sms_widget(c.user, event.context)}
      </%base:rounded_block>
    </%def>
    <%def name="description()">
      ${_("%(user_link)s has sent an sms to the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="privatemessage_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <div class="thread">
        <div class="logo">
          <img src="${url(controller='user', action='logo', id=event.private_message.sender.id, width=50)}" />
        </div>
        <div class="message">
          <div class="truncated">${h.nl2br(event.message_text())}</div>
          <span class="event-time">${event.when()}</span>
        </div>
        <div style="clear: both"></div>
      </div>
    </%def>
    <%def name="action_link()">${_('Reply')}</%def>
    <%def name="action()">
      <%base:rounded_block>
      <form method="post" action="${url(controller='messages', action='reply', id=event.private_message.id)}"
            id="message_reply_form" class="wallForm">
        ${h.input_area('message', '', rows=2)}
        <div class="line">
          ${h.input_submit(_('Send reply'), class_='btn action_submit')}
        </div>
      </form>
      </%base:rounded_block>
    </%def>
    <%def name="description()">
      %if event.user != c.user:
        ${_("%(user_link)s has sent you a private message \"%(msg_link)s\".") % \
           dict(user_link=h.object_link(event.user),
                msg_link=h.object_link(event.private_message)) | n}
      %else:
        ${_("%(user_link)s has sent %(recipient_link)s a private message \"%(msg_link)s\".") % \
           dict(user_link=h.object_link(event.user),
                recipient_link=h.object_link(event.recipient),
                msg_link=h.object_link(event.private_message)) | n}
      %endif
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupmember_joined(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="when()">${event.when()}</%def>
    <%def name="description()">
      ${_("%(user_link)s joined the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupmember_left(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="when()">${event.when()}</%def>
    <%def name="description()">
      ${_("%(user_link)s left the group %(group_link)s.") % \
         dict(user_link=h.object_link(event.user),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupsubject_start(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <div class="subject_link">
        ${h.object_link(event.subject)}
      </div>
    </%def>
    <%def name="description()">
      ${_("The group %(group_link)s has started watching the subject %(subject_link)s.") % \
         dict(subject_link=h.object_link(event.subject),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="groupsubject_stop(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="content()">
      <div class="subject_link">
        ${h.object_link(event.subject)}
      </div>
    </%def>
    <%def name="description()">
      ${_("The group %(group_link)s has stopped watching the subject %(subject_link)s.") % \
         dict(subject_link=h.object_link(event.subject),
              group_link=h.object_link(event.context)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="page_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has created a page %(page_link)s in the subject %(subject_link)s.") % \
         dict(subject_link=h.object_link(event.context),
              page_link=h.object_link(event.page),
              user_link=h.object_link(event.user)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="page_modified(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()"></%def>
    <%def name="description()">
      ${_("%(user_link)s has modified a page %(page_link)s in the subject %(subject_link)s.") % \
         dict(subject_link=h.object_link(event.context),
              page_link=h.object_link(event.page),
              user_link=h.object_link(event.user)) | n}
    </%def>
  </%self:wall_entry>
</%def>