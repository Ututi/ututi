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
      <img id="group-logo" src="${h.url_for(controller='group', action='logo', id=c.group.id, width=70)}" alt="logo" />
    %endif
    <div class="structured_info">
      <h4>${c.group.title}</h4>
      <span class="small XXX">VU | ArchFak</span><br/>
      <a class="small" href="mailto:${c.group.id}@${c.mailing_list_host}" title="${_('Mailing list address')}">${c.group.id}@${c.mailing_list_host}</a><br/>
      <span class="small">${len(c.group.members)} ${_('members')}</span>
    </div>
    <div class="description small">
      ${c.group.description}
    </div>
    <span class="portlet-link">
      <a class="small" href="${h.url_for(controller='group', action='edit', id=c.group.id)}" title="${_('Edit group settings')}">${_('Edit')}</a>
    </span>
    <br style="clear: right;" />
  </%self:portlet>

  <%self:portlet id="group_changes_portlet" portlet_class="inactive XXX">
    <%def name="header()">
      ${_('Latest changes')}
    </%def>
    <table class="group-changes" class="changes-table">
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
      <a class="small" href="${h.url_for(controller='group', action='changes', id=c.group.id)}" title="${_('More')}">${_('More')}</a>
    </span>
    <br style="clear: right;" />
  </%self:portlet>
</div>
</%def>


<h1>${c.group.title}, ${c.group.year.year}</h1>

<div>
${c.group.description}
</div>
