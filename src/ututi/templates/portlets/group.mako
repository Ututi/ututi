<%inherit file="/portlets/base.mako"/>

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
      <a ${h.trackEvent(c.group, 'subjects', 'portlet_footer')|n}
         class="more"
         href="${url(controller='group', action='subjects', id=group.group_id)}"
         title="${_('All watched subjects')}">${_('All watched subjects')}</a>
    </div>
  </%self:portlet>
</%def>
