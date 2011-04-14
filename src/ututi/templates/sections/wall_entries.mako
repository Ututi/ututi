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
</%def>

<%def name="wall_entries(events, per_page=20)">
  <%
  this_page, other = events[:per_page], events[per_page:]
  %>
  %for event in this_page:
    ${event.wall_entry()}
  %endfor
  %if other:
    <div class="more-events click2fade">
      <a class="click hide" href="#older-events">${_("See older events...")}</a>
      <div class="show">
        ${wall_entries(other, per_page)}
      </div>
    </div>
  %endif
</%def>

<%def name="hide_button(event)">
  <div class="hide-button-container">
    <form method="POST" action="${url(controller='wall', action='hide_event')}">
      <div>
        <input class="event-type" name="event_type" type="hidden" value="${event.event_type}" />
        <input class="hide-button" type="image" src="/img/icons.com/close.png" title="${_('Ignore events like this')}" />
      </div>
    </form>
  </div>
</%def>

<%def name="wall_entry(event)">
<div class="wall-entry ${caller.classes()} type_${event.event_type}" id="wall-event-${event.id}">
  %if hasattr(caller, 'heading'):
  <div class="event-heading">
    %if hasattr(c, 'events_hidable') and c.events_hidable and c.user is not None:
      ${hide_button(event)}
    %endif
    <span class="event-title">
      ${caller.heading()}
    </span>
    <span class="event-time">
      ${h.when(event.created)}
    </span>
  </div>
  %endif
  <div class="event-body">
    ${caller.body()}
  </div>
</div>
</%def>

<%def name="thread_reply(author_id, message, created_on, attachments=None, event_id=None)">
  <div class="reply">
    <div class="logo">
      <img src="${url(controller='user', action='logo', id=author_id, width=30)}" />
    </div>
    <div class="content">
      <span class="reply-author link-color">${h.user_link(author_id)}:</span>
      <span class="event-content truncated">${h.wall_fmt(message)}</span>
      %if attachments:
      <ul class="file-list">
        %for file in attachments:
        <li><a href="${file.url()}">${file.title}</a></li>
        %endfor
      </ul>
      %endif
      <div class="closing">
        <span class="event-time">${h.when(created_on)}</span>
        %if c.user is not None:
        <span class="actions">
          <a href="#reply" class="action-block-link">${_('Reply')}</a>
        </span>
        %endif
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
    original = event
    if hasattr(event, 'conversation'):
      messages = event.conversation
    elif hasattr(event, 'children') and event.event_type in ['mailinglist_post_created', 'forum_post_created', 'private_message_sent']:
      messages = event.children
      if messages:
        original = messages[0]
        messages.append(event)
        messages = messages[1:]
    elif hasattr(event, 'comments'):
      messages = event.comments
    else:
      messages = []
  %>
  <div class="thread">
    %if head_message:
    <div class="logo">
      <img src="${url(controller='user', action='logo', id=original.author_id, width=50)}" />
    </div>
    %endif
    <div class="content">
      %if hasattr(caller, 'headline'):
      <div class="event-heading">
        %if hasattr(c, 'events_hidable') and c.events_hidable and c.user is not None:
          ${hide_button(event)}
        %endif
        <span class="event-title">
          ${caller.headline()}
        </span>
      </div>
      %endif
      %if head_message:
        <%
           message = ''
           if original.event_type == 'mailinglist_post_created':
               message = original.ml_message
           elif original.event_type == 'forum_post_created':
               message = original.fp_message
        %>
        <span class="event-content truncated">${h.wall_fmt(message)}</span>
        %if hasattr(original, 'attachments'):
        <ul class="file-list">
          %for file in original.attachments:
          <li><a href="${file.url()}">${file.title}</a></li>
          %endfor
        </ul>
        %endif
        <div class="closing">
          <span class="event-time">${h.when(original.created)}</span>
          %if c.user is not None:
          <span class="actions">
            <a href="#reply" class="action-block-link">${_('Reply')}</a>
          </span>
          %endif
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
              <a class="click" href="#older-messages">
                ${_("Show older messages (%(message_count)s)") % dict(message_count=len(hidden))}
              </a>
            </div>
            <div class="show">
              %for msg in hidden:
                ${thread_reply(**h.thread_reply_dict(msg))}
              %endfor
            </div>
          </div>
        %endif
        %for msg in messages:
          ${thread_reply(**h.thread_reply_dict(msg))}
        %endfor
      </div>
      %if c.user is not None:
      <div class="reply">
        <%
           if original.event_type == 'private_message_sent':
               reply_url = url(controller='wall', action='privatemessage_reply', msg_id=event.private_message_id)
           elif original.event_type == 'forum_post_created':
               reply_url = url(controller='wall', action='forum_reply', group_id=original.object_id, category_id=original.fp_category_id, thread_id=original.fp_thread_id)
           elif original.event_type == 'mailinglist_post_created':
               reply_url = url(controller='wall', action='mailinglist_reply', thread_id=original.ml_thread_id, group_id=original.ml_group_id)
           else:
               reply_url = url(controller='wall', action='eventcomment_reply', event_id=event.id)
        %>
        <div class="action-tease">${_("Write a reply")}</div>
        <div class="action-block">
          <form name="reply-form" method="POST" action="${reply_url}">
            <textarea rows="3" cols="50" class="reply-text" name="message"></textarea>
            <div>
              ${h.input_submit(_('Send reply'), class_='btn dark reply-button')}
              <a class="action-block-cancel" href="#cancel-reply">${_("Cancel")}</a>
            </div>
          </form>
        </div>
      </div>
      %endif
    </div>
  </div>
</%def>

<%def name="grouped_files(event)">
  <div class="wall-subentry">
    <%self:file_description event="${event}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </div>
  <% children = [ch for ch in getattr(event, 'children', []) if ch.md5 is not None] %>
  %if children:
    <div class="click2show">
      <div class="click hide event-children-link">
        <% cccount = sum([len(getattr(ch, 'comments', [])) for ch in children]) %>
        (
        ${ungettext("and %(count)s more file", "and %(count)s more files", len(children)) % dict(count=len(children))}
        %if cccount:
          ${ungettext("with %(count)s comment", "with %(count)s comments", cccount) % dict(count=cccount)}
        %endif
        )
      </div>
      <div class="show">
        %for child in children:
          <div class="wall-subentry">
            <%self:file_description event="${child}"/>
            <%self:event_conversation event="${child}" head_message="${False}" />
          </div>
        %endfor
      </div>
    </div>
  %endif
</%def>

<%def name="file_description(event)">
  <div class="file-description">
    <div class="title">
      %if event.file_deleted_on is not None:
        ${event.filename}
      %else:
        ${h.content_link(event.file_id)}
      %endif
    </div>
    <span class="event-time">${h.when(event.created)}</span>
    %if c.user is not None:
    <span class="actions">
      <a href="#reply" class="action-block-link">
        ## TRANSLATORS: translate this as a verb 'Comment'
        ${_('comment_on_wall')}
      </a>
    </span>
    %endif
  </div>
</%def>

<%def name="page_description(evt)">
  <div class="page-description">
    <div class="title">
      %if evt.page_deleted_on is not None:
        ${evt.page_title}
      %else:
        ${h.content_link(evt.page_id)}
      %endif
    </div>
    <span class="event-time">${h.when(evt.created)}</span>
    %if c.user is not None:
    <span class="actions">
      <a href="#reply" class="action-block-link">
        ## TRANSLATORS: translate this as a verb 'Comment'
        ${_('comment_on_wall')}
      </a>
      %if evt.page_deleted_on is None:
      <a href="${url(controller='content', action='get_content', id=evt.page_id, next_action='edit')}">
        ## TRANSLATORS: translate this as a verb 'Edit'
        ${_("edit_on_wall")}
      </a>
      %endif
    </span>
    %endif
  </div>
</%def>

<%def name="file_uploaded(event)">
  %if event.context_type == 'subject':
    %if event.md5 is None:
      ${folder_created_subject(event)}
    %else:
      ${file_uploaded_subject(event)}
    %endif
  %elif event.context_type == 'group':
    %if event.md5 is None:
      ${folder_created_group(event)}
    %else:
      ${file_uploaded_group(event)}
    %endif
  %endif
</%def>

<%def name="file_uploaded_subject(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable subject-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has uploaded a new file") % \
         dict(user_link=h.user_link(event.author_id)) | n}
      <span class="recipient">${h.content_link(event.object_id)}</span>
    </%def>
    <%self:grouped_files event="${event}" />
  </%self:wall_entry>
</%def>

<%def name="folder_created_subject(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has created a new folder %(folder_name)s") % \
         dict(user_link=h.user_link(event.author_id),
              folder_name=event.folder) | n}
      <span class="recipient">${h.content_link(event.object_id)}</span>
    </%def>
  </%self:wall_entry>
</%def>

<%def name="file_uploaded_group(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable group-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has uploaded a new file") % \
         dict(user_link=h.user_link(event.author_id)) | n}
      <span class="recipient">${h.content_link(event.object_id)}</span>
    </%def>
    <%self:grouped_files event="${event}" />
  </%self:wall_entry>
</%def>

<%def name="folder_created_group(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has created a new folder %(folder_name)s") % \
         dict(user_link=h.user_link(event.author_id),
              folder_name=event.folder) | n}
      <span class="recipient">${h.content_link(event.object_id)}</span>
    </%def>
  </%self:wall_entry>
</%def>

<%def name="subject_modified(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has edited the subject %(subject_link)s") % \
         dict(user_link=h.user_link(event.author_id),
              subject_link=h.content_link(event.object_id)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="subject_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">subject-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has created the subject %(subject_link)s") % \
         dict(user_link=h.user_link(event.author_id),
              subject_link=h.content_link(event.object_id)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="group_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has created the group %(group_link)s") % \
         dict(user_link=h.user_link(event.author_id),
              group_link=h.content_link(event.object_id)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="mailinglist_post_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable no-icon</%def>
    <%self:event_conversation event="${event}">
      <%def name="headline()">
        <%
           msg = event
           if hasattr(event, 'children') and len(event.children) > 0:
             msg = event.children[0]
        %>
        ${h.user_link(msg.ml_author)}
        <span class="recipient">${h.content_link(msg.object_id)}</span>
      </%def>
    </%self:event_conversation>
  </%self:wall_entry>
</%def>

<%def name="teacher_message(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable message-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has sent a message to the group %(group_link)s") % \
         dict(user_link=h.user_link(event.author_id),
              group_link=h.content_link(event.object_id)) | n}
    </%def>
    ## The following snippet is copied from event_conversation def.
    ## This is a temporary solution as teacher messages should be
    ## handled the same way as any other messages.
    <div class="thread">
      <div class="logo">
        <img src="${url(controller='user', action='logo', id=event.author_id, width=50)}" />
      </div>
      <div class="content">
        <span class="event-content truncated">${h.wall_fmt(event.data)}</span>
      </div>
    </div>
  </%self:wall_entry>
</%def>

<%def name="moderated_post_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable message-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has posted a new message %(message_link)s to the group's %(group_link)s moderation queue") % \
           dict(user_link=h.user_link(event.ml_author),
                group_link=h.content_link(event.object_id),
                message_link=h.content_link(event.message_id)) | n}
    </%def>
    ## The following snippet is copied from event_conversation def.
    ## This markup should probably be shared but I don't know the
    ## best way to do that yet.
    <div class="thread">
      <div class="logo">
        <img src="${event.ml_author_logo_link}" />
      </div>
      <div class="content">
        <span class="event-content truncated">${h.wall_fmt(event.ml_message)}</span>
        %if hasattr(event, 'attachments'):
        <ul class="file-list">
          %for file in event.attachments:
          <li><a href="${file.url()}">${file.title}</a></li>
          %endfor
        </ul>
        %endif
        <div class="closing">
          <span class="event-time">${h.when(event.created)}</span>
          %if c.user is not None:
          <span class="actions">
            <a href="#moderate" class="action-block-link">Moderate</a>
          </span>
          %endif
        </div>
        %if c.user is not None:
        <div class="action-block">
          <div class="content">
            <div class="moderation-actions">
              <div class="loading-message">
                ${_('Working...')}
              </div>
            <div class="error-message">
              ${_('Error: could not reach server or this message was already moderated. Please try refreshing the page.')}
            </div>
              <div class="moderation-action-buttons">
                ${h.button_to(_('Approve'), url=url(controller='mailinglist', action='approve_post_from_list', thread_id=event.ml_thread_id, id=event.ml_group_id), class_='btn btn-approve')}
                ${h.button_to(_('Reject'), url=url(controller='mailinglist', action='reject_post_from_list', thread_id=event.ml_thread_id, id=event.ml_group_id), class_='btn btn-reject')}
              </div>
            </div>
          </div>
        </div>
        %endif
      </div>
    </div>
  </%self:wall_entry>
</%def>

<%def name="forum_post_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable message-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has posted a new message %(message_link)s in the forum %(group_link)s") % \
         dict(user_link=h.user_link(event.author_id),
              group_link=h.content_link(event.object_id),
              message_link=h.content_link(event.post_id)) | n}
    </%def>
    <%self:event_conversation event="${event}"/>
  </%self:wall_entry>
</%def>

<%def name="sms_message_sent(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable sms-event</%def>
    <%def name="heading()">
      %if c.user is not None and c.user.id == event.author_id:
        ${_("You have sent an sms to the group %(group_link)s") % \
           dict(group_link=h.content_link(event.object_id)) | n}
      %else:
        ${_("%(user_link)s has sent an sms to the group %(group_link)s") % \
           dict(user_link=h.user_link(event.author_id),
                group_link=h.content_link(event.object_id)) | n}
      %endif
    </%def>
    <div class="thread">
      <div class="logo">
        <img src="${url(controller='users', action='logo', id=event.author_id, width=50)}" />
      </div>
      <div class="content">
        <span class="event-content truncated">${h.wall_fmt(event.sms_message)}</span>
        <div class="closing">
          <span class="event-time">${h.when(event.created)}</span>
          %if c.user is not None:
          <span class="actions">
            <a href="#moderate" class="action-block-link">${_('Reply')}</a>
          </span>
          %endif
        </div>
        %if c.user is not None:
        <div class="action-block">
          <div class="content">
            ${sms.sms_widget_tiny(c.user, event.sms_group)}
          </div>
        </div>
        %endif
      </div>
    </div>
  </%self:wall_entry>
</%def>

<%def name="member_joined(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event ${hasattr(event, 'children') and 'click2show' or ''}</%def>
    <%def name="heading()">
      %if hasattr(event, 'children'):
        ${ungettext("%(user_link)s and %(count)s more person have joined the group %(group_link)s",
                    "%(user_link)s and %(count)s more people have joined the group %(group_link)s",
                    len(event.children)) % \
           dict(user_link=h.user_link(event.author_id),
                group_link=h.content_link(event.object_id),
                count=len(event.children)) | n}
      %else:
        ${_("%(user_link)s has joined the group %(group_link)s") % \
           dict(user_link=h.user_link(event.author_id),
                group_link=h.content_link(event.object_id)) | n}
      %endif
    </%def>
    %if hasattr(event, 'children'):
      <span class="click hide event-children-link">${_("show all")}</span>
      <div class="show other_members">
        %for ch in event.children:
          ${h.user_link(ch.author_id)}
        %endfor
      </div>
    %endif
  </%self:wall_entry>
</%def>

<%def name="member_left(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">group-event ${hasattr(event, 'children') and 'click2show' or ''}</%def>
    <%def name="heading()">
      %if hasattr(event, 'children'):
        ${ungettext("%(user_link)s and %(count)s more person have left the group %(group_link)s",
                    "%(user_link)s and %(count)s more people have left the group %(group_link)s",
                    len(event.children)) % \
           dict(user_link=h.user_link(event.author_id),
                group_link=h.content_link(event.object_id),
                count=len(event.children)) | n}
      %else:
        ${_("%(user_link)s has left the group %(group_link)s") % \
           dict(user_link=h.user_link(event.author_id),
                group_link=h.content_link(event.object_id)) | n}
      %endif
    </%def>
    %if hasattr(event, 'children'):
      <span class="click hide event-children-link">${_("show all")}</span>
      <div class="show other_members">
        %for ch in event.children:
          ${h.user_link(ch.author_id)}
        %endfor
      </div>
    %endif
  </%self:wall_entry>
</%def>

<%def name="group_started_watching_subject(event)">
  <%self:wall_entry event="${event}">
    %if c.user is not None and event.object_id in c.user.group_ids:
    <%def name="classes()">group-event</%def>
    %else:
    <%def name="classes()">subject-event</%def>
    %endif
    <%def name="heading()">
      ${_("The group %(group_link)s has started watching the subject %(subject_link)s") % \
         dict(subject_link=h.content_link(event.subject_id),
              group_link=h.content_link(event.object_id)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="group_stopped_watching_subject(event)">
  <%self:wall_entry event="${event}">
    %if c.user is not None and event.object_id in c.user.group_ids:
    <%def name="classes()">group-event</%def>
    %else:
    <%def name="classes()">subject-event</%def>
    %endif
    <%def name="heading()">
      ${_("The group %(group_link)s has stopped watching the subject %(subject_link)s") % \
         dict(subject_link=h.content_link(event.subject_id),
              group_link=h.content_link(event.object_id)) | n}
    </%def>
  </%self:wall_entry>
</%def>

<%def name="page_created(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable subject-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has created a page %(page_link)s") % \
         dict(page_link=h.content_link(event.page_id),
              user_link=h.user_link(event.author_id)) | n}
      <span class="recipient">${h.content_link(event.object_id)}</span>
    </%def>
    <%self:page_description evt="${event}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </%self:wall_entry>
</%def>

<%def name="page_modified(event)">
  <%self:wall_entry event="${event}">
    <%def name="classes()">minimizable subject-event</%def>
    <%def name="heading()">
      ${_("%(user_link)s has modified a page %(page_link)s") % \
         dict(page_link=h.content_link(event.page_id),
              user_link=h.user_link(event.author_id)) | n}
      <span class="recipient">${h.content_link(event.object_id)}</span>
    </%def>
    <%self:page_description evt="${event}"/>
    <%self:event_conversation event="${event}" head_message="${False}" />
  </%self:wall_entry>
</%def>
