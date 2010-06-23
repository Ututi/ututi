<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/portlets/forum.mako" import="*"/>
<%namespace file="/group/base.mako" import="*"/>

<%def name="title()">
  ${c.category.title}
</%def>

<%def name="portlets()">
  <div id="sidebar" class="forum-sidebar">
    % if c.category is not None:
      ${forum_info_portlet()}
      <!-- forum crosslink -->
      % if c.category.id == 1:
        ${bugs_forum_posts_portlet()}
      % elif c.category.id == 2:
        ${community_forum_posts_portlet()}
      % endif
    % endif

    % if c.group_id is not None:
      ${group_sidebar()}
    % endif
  </div>
</%def>

%if c.group_id is not None:
  ${group_menu()}
%endif

${next.body()}
