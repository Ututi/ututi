<%inherit file="/base.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
<div id="sidebar">
  <%self:portlet id="group_info_portlet">
    <%def name="header()">
      ${_('Group information')}
    </%def>
    %if c.group.logo is not None:
      <img id="group-logo" src="${url(controller='group', action='logo', id=c.group.group_id, width=70)}" alt="logo" />
    %endif
    <div class="structured_info">
      <h4>${c.group.title}</h4>
      <span class="small">${c.group.location and ' | '.join(c.group.location.path)}</span><br/>
      <a class="small" href="mailto:${c.group.group_id}@${c.mailing_list_host}" title="${_('Mailing list address')}">${c.group.group_id}@${c.mailing_list_host}</a><br/>
      <span class="small">${len(c.group.members)} ${_('members')}</span>
    </div>
    <div class="description small">
      ${c.group.description}
    </div>
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='edit', id=c.group.group_id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
    </span>
    <br style="clear: right;" />
  </%self:portlet>

  <%self:portlet id="group_changes_portlet" portlet_class="inactive XXX">
    <%def name="header()">
      ${_('Latest changes')}
    </%def>
    <table class="group-changes">
      <tr>
        <td class="change-category">${_('New files')}</td>
        <td class="change-count">2</td>
      </tr>
      <tr>
        <td class="change-category">${_('New messages')}</td>
        <td class="change-count">123</td>
      </tr>
      <tr>
        <td class="change-category">${_('Wiki edits')}</td>
        <td class="change-count">0</td>
      </tr>
    </table>
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='changes', id=c.group.group_id)}" title="${_('More')}">${_('More')}</a>
    </span>
    <br style="clear: right;" />
  </%self:portlet>

  <%self:portlet id="group_members_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Recently seen')}
    </%def>
    %for member in c.group.last_seen_members[:3]:
    <div class="user-link">
      <a href="${url(controller='user', action='index', id=member.id)}" title="${member.fullname}">
        %if member.logo is not None:
          <img src="${url(controller='user', action='logo', id=member.id, width=40)}" alt="${member.fullname}"/>
        %else:
          ${h.image('/images/user_logo_small.png', alt=member.fullname)|n}
        %endif
          <span class="small">${member.fullname}</span>
      </a>

    </div>
    %endfor
    <br style="clear: both;" />
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='members', id=c.group.group_id)}" title="${_('More')}">${_('More') | h.ellipsis}</a>
    </span>
    <br style="clear: both;" />
  </%self:portlet>


  <%self:portlet id="watched_subjects_portlet" portlet_class="inactive XXX">
    <%def name="header()">
      ${_('Watched subjects')}
    </%def>
    %for subject in c.group.watched_subjects:
    <div>
      <a href="${subject.url()}">
          ${subject.title}
      </a>
    </div>
    %endfor
    <br style="clear: both;" />
    <span class="portlet-link">
      <a class="small" href="${url(controller='group', action='subjects', id=c.group.group_id)}" title="${_('More')}">${_('More')}</a>
    </span>
    <br style="clear: both;" />
  </%self:portlet>

</div>
</%def>

%if c.group.show_page:
<div id="group_page" class="content-block">
  <div class="rounded-header">
    <div class="rounded-right">
      <span class="header-links">
        <a href="${url(controller='group', action='group_home', id=c.group.group_id, do='hide_page')}" title="${_('Hide group page')}">
          ${_('Hide')}
        </a>
      </span>
      <h3>${_("Group front page")}</h3>

    </div>
  </div>
  <div class="content">
    %if c.group.page != '':
    ${c.group.page|n,decode.utf8}
    %else:
    ${_("The group's page is empty. Enter your description.")}
    %endif
    <div class="footer">
      <a class="btn" href="${url(controller='group', action='edit_page', id=c.group.group_id)}" title="${_('Edit group front page')}">
        <span>${_('Edit')}</span>
      </a>
    </div>
  </div>
</div>
%endif

<h1>${c.group.title}, ${c.group.year.year}</h1>

<div>
${c.group.description}
</div>
