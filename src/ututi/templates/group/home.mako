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
  ${group_forum_portlet()}
  ${group_files_portlet()}
  ${group_watched_subjects_portlet()}
  ${group_members_portlet()}
</div>
</%def>

%if c.group.show_page:
<div id="group_page" class="content-block">
  <div class="hdr">
    <span class="huge" style="float: left;">${_("Group front page")}</span>
    <div style="float: left; margin-top: 4px; margin-left: 20px;">
      <a class="btn" href="${url(controller='group', action='edit_page', id=c.group.group_id)}" title="${_('Edit group front page')}">
        <span>${_('Edit')}</span>
      </a>
    </div>
    <br class="clear-left" />
  </div>
  <div class="content">
    %if c.group.page != '':
    ${h.html_cleanup(c.group.page)|n,decode.utf8}
    %else:
      ${_("The group's page is empty. Enter your description.")}
    %endif
  </div>
</div>
%endif

<h1>${_("What's new?")}
  ${h.image('/images/details/icon_question.png',
            alt=_('A group can watch subjects that it is studying at the moment. Changes in watched subjects are shown to all classmates.'),
            class_='tooltip')|n}
</h1>

<ul id="event_list">
% for event in c.events:
<li>
  ${event.render()|n} <span class="event_time">(${event.when()})</span>
</li>
% endfor
</ul>
