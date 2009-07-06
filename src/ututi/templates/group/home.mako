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

  </%self:portlet>
</div>
</%def>


<h1>${c.group.title}, ${c.group.year.year}</h1>

<div>
${c.group.description}
</div>
