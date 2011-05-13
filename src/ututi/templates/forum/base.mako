<%inherit file="/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/portlets/forum.mako" import="*"/>
<%namespace file="/group/base.mako" import="*"/>

<%def name="title()">
  ${c.category.title}
</%def>

%if c.group_id is not None:
  ${group_menu()}
%endif

${next.body()}
