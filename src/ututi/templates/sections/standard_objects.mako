<%namespace file="/sections/standard_buttons.mako" import="close_button, watch_button, teach_button" />
<%namespace file="/widgets/sms.mako" import="sms_widget" />

<%def name="subject_listitem_button(subject)">
## Renders appropriate action button.
## Probably not a good idea this implicit thing.

  %if c.user.is_teacher:
    %if c.user.teaches(subject):
      ${close_button(url(controller='profile', action='unteach_subject', subject_id=subject.id), class_='unteach-button')}
    %else:
      ${teach_button(url(controller='profile', action='teach_subject', subject_id=subject.id))}
    %endif
  %else:
    %if c.user.watches(subject):
      ${close_button(url(controller='profile', action='unwatch_subject', subject_id=subject.id), class_='unwatch-button')}
    %else:
      ${watch_button(url(controller='profile', action='watch_subject', subject_id=subject.id))}
    %endif
  %endif
</%def>

<%def name="subject_listitem(subject, n=0, with_buttons=True)">
  <div class="u-object subject-description ${'with-top-line' if n else ''}">
    %if c.user is not None and with_buttons:
      ${subject_listitem_button(subject)}
    %endif
    <div>
      <dt>
        <a class="subject-title" href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
      </dt>
      <dd class="location-tags">
        %for index, tag in enumerate(subject.location.hierarchy(True)):
        <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
        |
        %endfor
      </dd>
      %if subject.teacher_repr:
      <dd class="lecturer">
        ${_('Lect.')} ${subject.teacher_repr}
      </dd>
      %endif
    </div>
    <div style="margin-top: 5px">
      <dd class="files">
        ${h.item_file_count(subject.id)}
      </dd>
      <dd class="pages">
        ${h.subject_page_count(subject.id)}
      </dd>
      <dd class="watch-count">
        <%
           user_count = subject.user_count()
           group_count = subject.group_count()
           %>
        ${ungettext("%(count)s group", "%(count)s groups", group_count) % dict(count=group_count)}
        ${_('and')}
        ${ungettext("%(count)s member", "%(count)s members", user_count) % dict(count=user_count)}
      </dd>
    </div>
  </div>
</%def>

<%def name="subject_list(title, subjects, with_buttons=True)">
<div class="standard-portlet subject-list">
  <div class="large-header">
    <h2>${title}</h2>
  </div>
  <dl>
  %for index, subject in enumerate(subjects):
    ${subject_listitem(subject, index, with_buttons)}
  %endfor
  </dl>
</div>
</%def>

<%def name="subject_listitem_search_results(subject, n=0, with_buttons=True)">
  <div class="u-object subject-description save-space-right ${'with-top-line' if n else ''}">
    %if c.user is not None and with_buttons:
      %if c.user.is_teacher:
        %if not c.user.teaches(subject):
          ${teach_button(subject.url(action='teach'))}
        %endif
      %else:
        %if not c.user.watches(subject):
          ${watch_button(subject.url(action='watch'))}
        %endif
      %endif
    %endif
    <div>
      <dt>
        <a class="subject-title" href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
      </dt>
    </div>
    <div style="margin-top: 5px">
      <dd class="location-tags">
        %for index, tag in enumerate(subject.location.hierarchy(True)):
        <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
        |
        %endfor
      </dd>
      %if subject.teacher_repr:
      <dd class="lecturer">
        ${_('Lect.')} ${subject.teacher_repr}
      </dd>
      %endif
    </div>
  </div>
</%def>

<%def name="group_listitem_base(group, n=0)">
  <%def name="title(group)">
    <div>
      <div class="logo">
        %if group.has_logo():
        ${h.image(url(controller='group', action='logo', id=group.group_id, width=35, height=35), alt='logo', class_='group-logo')|n}
        %else:
        <img src="${url(controller='group', action='logo', id=group.group_id, width=36, height=35)}" alt="logo" />
        %endif
      </div>
      <div class="group-title">
        <dt>
          <a ${h.trackEvent(Null, 'groups', 'title', 'profile')} href="${group.url()}">${group.title}</a>
          <% n_members = h.group_members_count(group.id) %>
          (${ungettext("%(count)s member", "%(count)s members", n_members) % dict(count=n_members)})
        </dt>
        <div><dd>
          <a class="tiny-text grey-text" ${h.trackEvent(Null, 'groups', 'mailinglist', 'profile')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}">
            ${group.group_id}@${c.mailing_list_host}
          </a>
        </dd></div>
      </div>
    </div>
  </%def>
  <div class="u-object group-description ${'with-top-line' if n else ''}">
    %if hasattr(caller, 'title'):
      ${caller.title(group)}
    %else:
      ${title(group)}
    %endif
    ${caller.body()}
  </div>
</%def>

<%def name="group_listitem(group, n=0)">
  <%self:group_listitem_base group="${group}" n="${n}">
  <div class="group-actions">
      %if group.mailinglist_enabled:
      <dd class="messages">
        <a ${h.trackEvent(Null, 'groups', 'write_message', 'profile')} href="${url(controller='mailinglist', action='new_thread', id=group.group_id)}" title="${_('Mailing list address')}">
          ${_('Write message')}
        </a>
      </dd>
      <dd class="messages">
        <a ${h.trackEvent(Null, 'groups', 'messages_or_forum', 'profile')} href="${url(controller='mailinglist', action='index', id=group.group_id)}">
          ${_('Group messages')}
        </a>
      </dd>
      %else:
      <dd class="messages">
        <a  ${h.trackEvent(Null, 'groups', 'write_message', 'profile')} href="${url(controller='forum', action='new_thread', id=group.group_id, category_id=group.forum_categories[0].id)}">
          ${_('Write message')}
        </a>
      </dd>
      <dd class="messages">
        <a ${h.trackEvent(Null, 'groups', 'messages_or_forum', 'profile')} href="${url(controller='forum', action='categories', id=group.group_id)}">
          ${_('Group forum')}
        </a>
      </dd>
      %endif

      %if group.wants_to_watch_subjects:
      <dd class="subjects">
        <a ${h.trackEvent(Null, 'groups', 'subjects', 'profile')} href="${url(controller='group', action='subjects', id=group.group_id)}">
          ${_('Group subjects')}
        </a>
      </dd>
      %endif
      %if group.has_file_area:
      <dd class="files">
        <a ${h.trackEvent(Null, 'groups', 'files', 'profile')} href="${url(controller='group', action='files', id=group.group_id)}">
          ${_('Group files')}
        </a>
      </dd>
      %endif
  </div>
  </%self:group_listitem_base>
</%def>

<%def name="group_listitem_teacherdashboard(group)">
  <%self:group_listitem_base group="${group}" n="${0}">
    <%def name="title(group)">
      <div class="hide_me">
        <div style="position: absolute; left: 0;">
        <a href="${url(controller='profile', action='edit_student_group', id=group.id)}" class="edit_group" title="${_('Edit group')}">
          ${h.image('/images/details/icon_edit.png', alt=_('Edit this group'))}
        </a>
        </div>
        <div style="position: absolute; left: 15px;">
        <form method="POST" action="${url(controller='profile', action='delete_student_group')}">
          <div>
            <input type="hidden" name="group_id" value="${group.id}" class="event_type"/>
            <input type="image" src="/images/details/icon_delete.png" title="${_('Delete this group')}" class="delete_group" name="delete_group_${group.id}"/>
          </div>
        </form>
        </div>
      </div>
      <div>
        <div class="group-title">
          <dt>
            ${group.title}
          </dt>
          <dd class="group-email"> ${group.email} </dd>
          %if group.group:
          <dd class="location-tags">
            %for index, tag in enumerate(group.group.location.hierarchy(True)):
              %if n:
                |
              %endif
            <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
            %endfor
          </dd>
          %endif
        </div>
      </div>
    </%def>

  <div class="group-actions">
      <span class="tiny-text" style="margin-right: 5px">
        ${_('Contact the group:')}
      </span>
      <dd class="messages">
        <a href="#" title="${_('Send message')}" class="send_message click-action" id="send_message_${group.id}">
          ${_('Send message')}
        </a>
      </dd>
      %if group.group is not None:
      <dd class="sms">
        <a href="#" title="${_('Send SMS')}" class="send_sms click-action" id="send_sms_${group.id}">
          ${_('Send SMS')}
        </a>
      </dd>
      %endif
  </div>
  <div class="send_message_block click-action-block" id="send_message_${group.id}-block">
    <a class="${not active and 'inactive' or ''}" name="send-message"></a>
    <form method="POST" action="${url(controller='profile', action='studentgroup_send_message', id=group.id)}" class="inelement-form group-message-form" enctype="multipart/form-data">
      <input type="hidden" name="message_send_url" class="message_send_url" value="${url(controller='profile', action='studentgroup_send_message_js', id=group.id)}" />
      ${h.input_line('subject', _('Message subject:'), class_='message_subject wide-input')}
      <div class="formArea">
        <label>
          <textarea name="message" class="message" rows="5" rows="50"></textarea>
        </label>
      </div>
      <div class="formField">
        <label for="file">
          <span class="labelText">${_('Attachment:')}</span>
          <input type="file" name="file" />
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Send'), class_="btn message_send")}
      </div>
      <br class="clear-right" />
    </form>
  </div>
  <div class="message-sent hidden action-reply">
    ${_('Your message was successfully sent.')}
  </div>
  %if group.group is not None:
  <div class="send_sms_block click-action-block" id="send_sms_${group.id}-block">
    ${sms_widget(user=c.user, group=group.group, text='', parts=[])}
  </div>
  <div class="sms-sent hidden action-reply">
    ${_('Your SMS was successfully sent.')}
  </div>
  %endif
  </%self:group_listitem_base>
</%def>
