<%inherit file="/portlets/base.mako"/>

<%def name="portlet_file(file)">
  <li>
    <a href="${file.url()}" title="${file.title}">${h.ellipsis(file.title, 30)}</a>
    <input class="delete_url" type="hidden" value="${file.url(action='delete')}" />
  </li>
</%def>

<%def name="group_info_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>

  <%self:portlet id="group_info_portlet">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'home', 'portlet_header')|n} href="${group.url()}" title="${group.title}">${_('Group information')}</a>
    </%def>
    %if group.logo is not None:
      <img id="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=70, height=80)}" alt="logo" />
    %endif
    <div class="structured_info">
      <h4>${group.title}</h4>
      <span class="school-link"><a href="${group.location.url()}">${' | '.join(group.location.path)}</a></span><br />
      %if group.is_member(c.user):
        <a href="${url(controller='groupforum', action='new_thread', id=c.group.group_id)}" title="${_('Mailing list address')}">${group.group_id}@${c.mailing_list_host}</a><br />
      %endif
      <span>
        ${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count = len(group.members))}
      </span>
    </div>
    <div class="description small">
      ${group.description}
    </div>

    <div class="footer click2show">
      %if group.is_member(c.user):
      <div id="group_settings_toggle" class="click">${_("more settings")}</div>
      <div class="show" id="group_settings_block">
        %if group.is_subscribed(c.user):
        <a href="${group.url(action='unsubscribe')}" class="btn inactive"><span>${_("Do not get email")}</span></a>
        %else:
        <a href="${group.url(action='subscribe')}" class="btn"><span>${_("Get email")}</span></a>
        %endif
        <a href="${group.url(action='leave')}" class="btn warning"><span>${_("Leave group")}</span></a>
        %if group.is_admin(c.user):
        <a class="more" href="${url(controller='group', action='edit', id=group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
        %endif
      </div>
      %endif
    </div>
  </%self:portlet>
</%def>

<%def name="group_watched_subjects_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      <a ${h.trackEvent(c.group, 'subjects', 'portlet_header')|n} href="${group.url(action='subjects')}" title="${_('All watched subjects')}">${_('Watched subjects')}</a>
    </%def>
    %if not group.watched_subjects:
      ${_('Your group is not watching any subjects!')}
    %else:
    <ul id="group-subjects" class="subjects-list">
      % for subject in group.watched_subjects[:5]:
      <li>
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif
    <div class="footer">
      <span>
        ${h.button_to(_('choose subjects'), group.url(action='subjects'))}
        ${h.image('/images/details/icon_question.png', alt=_('Watching subjects means your group will be informed of all the changes that happen in these subjects: new files, new pages etc.'), class_='tooltip')|n}
      </span>
    </div>
  </%self:portlet>
</%def>

<%def name="group_forum_post_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="forum_post_portlet">
    <%def name="header()">
    <a href="${url(controller='groupforum', action='new_thread', id=group.group_id)}">${_('email your group')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Write an email to the group's forum - accessible by all your groupmates."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="group_invite_member_portlet(group=None)">
  <%
     if group is None:
         group = c.group
  %>
  <%self:action_portlet id="invite_member_portlet">
    <%def name="header()">
    <a href="${group.url(action='members')}">${_('invite groupmates')}</a>
    ${h.image('/images/details/icon_question.png',
            alt=_("Invite your groupmates to use Ututi with you."),
             class_='tooltip', style='margin-top: 4px;')|n}

    </%def>
  </%self:action_portlet>
</%def>
