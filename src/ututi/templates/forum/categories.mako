<%inherit file="/forum/base.mako" />
<%namespace file="/portlets/forum.mako" import="*"/>
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/forum/index.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${group_sidebar()}
</div>
</%def>

%if not c.group.forum_categories:
    <span id="no-categories" class="small">${_('No categories yet.')}</span>
%endif

% for category in c.group.forum_categories:
  ${forum_thread_list(category, n=5, class_='largerTopMargin')}
% endfor

% if h.check_crowds(['admin', 'moderator']):
<div style="margin-top: -7px">
  ${h.button_to(_('New category'), url(controller=c.controller, action='new_category', id=c.group_id))}
</div>
% endif
