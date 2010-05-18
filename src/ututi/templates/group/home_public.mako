<%inherit file="/base.mako" />
<%namespace file="/portlets/group.mako" import="*"/>
<%namespace file="/group/members.mako" import="group_members"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${group_info_portlet()}
</div>
</%def>

<h1>${c.group.title}</h1>
<div class="description">
  ${c.group.description}
</div>

%if c.group.page_public and c.group.page != '':
<div id="group_page">
${h.html_cleanup(c.group.page)|n,decode.utf8}
</div>
%endif

%if c.group.forum_is_public:
  <div id="group_forum" style="padding: 1em">
    %if c.group.mailinglist_enabled:
      ${h.link_to(_('Group mailing list archives'), url(controller='mailinglist', action='index', id=c.group.group_id))}
    %else:
      ${h.link_to(_('Group forum'), url(controller='forum', action='categories', id=c.group.group_id))}
    %endif
  </div>
%endif

<h2>${_('Group members')}</h2>
${group_members()}

<br style="clear: left;"/>
  ${h.button_to(_('Join the group'), url(controller='group', action='request_join', id=c.group.group_id))}
