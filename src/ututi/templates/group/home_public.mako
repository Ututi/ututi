<%inherit file="/group/base.mako" />
<%namespace file="/portlets/group.mako" import="*"/>
<%namespace file="/group/members.mako" import="group_members"/>
<%namespace file="/forum/index.mako" import="forum_thread_list"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="group_menu()">
</%def>

<h1 class="pageTitle">
  ${self.title()}
  <div style="float: right;">
    ${h.button_to(_('become a member'), url(controller='group', action='request_join', id=c.group.group_id))}
  </div>
</h1>

<div class="group_description">
  %if c.group.page_public and c.group.page != '':
    ${h.html_cleanup(c.group.page)|n,decode.utf8}
  %else:
    ${c.group.description}
  %endif
</div>

%if c.group.forum_is_public:
  %for category in c.group.forum_categories:
    ${forum_thread_list(category, n=10000)}
  %endfor
%endif

<h2>${_('Group members')}</h2>
${group_members()}

<br style="clear: left;"/>

