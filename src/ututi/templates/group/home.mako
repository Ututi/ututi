<%inherit file="/base.mako" />
<%namespace file="/portlets/group.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/group.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
  ${group_changes_portlet()}
  ${group_watched_subjects_portlet()}
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

<h1>${_("What's new?")}</h1>

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
