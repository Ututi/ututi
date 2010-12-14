<%namespace file="/sections/standard_buttons.mako" import="close_button, watch_button, teach_button" />

<%def name="subject_listitem_button(subject)">
## Renders appropriate action button.
## Probably not a good idea this implicit thing.

  %if c.user.is_teacher and c.user.teacher_verified:
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

<%def name="subject_listitem(subject, n, with_buttons=True)">
  <div class="u-object subject-description ${'with-top-line' if n else ''}">
    %if c.user is not None and with_buttons:
      ${subject_listitem_button(subject)}
    %endif
    <div>
      <dt>
        <a class="subject-title" href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
      </dt>
      <dd class="rating">
        ( ${_('Subject rating:')} ${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')} )
      </dd>
    </div>
    <div style="margin-top: 5px">
      <dd class="location-tags">
        %for index, tag in enumerate(subject.location.hierarchy(True)):
        <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
        |
        %endfor
      </dd>
      %if subject.lecturer:
      <dd class="lecturer">
        ${_('Lect.')} ${subject.lecturer}
      </dd>
      %endif
    </div>
    <div style="margin-top: 5px">
      <dd class="files">
        ${_('Files:')} ${h.subject_file_count(subject.id)}
      </dd>
      <dd class="pages">
        ${_('Wiki pages:')} ${h.subject_page_count(subject.id)}
      </dd>
      <dd class="watch-count">
        <%
           user_count = subject.user_count()
           group_count = subject.group_count()
           %>
        ${_('The subject is watched by:')}
        ${ungettext("<span class='orange'>%(count)s</span> user",
        "<span class='orange'>%(count)s</span> users",
        user_count) % dict(count=user_count)|n}
        ${_('and')}
        ${ungettext("<span class='orange'>%(count)s</span> group",
        "<span class='orange'>%(count)s</span> groups",
        group_count) % dict(count=group_count)|n}
      </dd>
    </div>
  </div>
</%def>

<%def name="subject_listitem_search_results(subject, n, with_buttons=True)">
  <div class="u-object subject-description save-space-right ${'with-top-line' if n else ''}">
    %if c.user is not None and with_buttons:
      %if c.user.is_teacher and c.user.teacher_verified:
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
      %if subject.lecturer:
      <dd class="lecturer">
        ${_('Lect.')} ${subject.lecturer}
      </dd>
      %endif
    </div>
  </div>
</%def>

<%def name="group_listitem_base(group, n)">
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
          <% n_members = h.group_members(group.id) %>
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

<%def name="group_listitem(group, n)">
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
      <div>
        <div class="logo">
          <img src="/images/details/icon_group_large.png" width="35" heigh="35" alt="logo" />
        </div>
        <div class="group-title">
          <dt>
            ${group.title}
          </dt>
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
          <div><dd class="group-email">
            ${group.email}
          </dd></div>
        </div>
      </div>
    </%def>

  <div class="group-actions">
  </div>
  </%self:group_listitem_base>
</%def>
