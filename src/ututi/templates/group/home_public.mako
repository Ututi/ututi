<%inherit file="/group/base.mako" />
<%namespace file="/portlets/group.mako" import="*"/>
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/group/members.mako" import="group_members"/>
<%namespace file="/forum/index.mako" import="forum_thread_list"/>

<%namespace file="/portlets/banners/base.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
${user_sidebar()}
</%def>

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

