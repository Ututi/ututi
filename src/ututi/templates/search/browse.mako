<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/anonymous_index/en.mako" import="universities_section"/>
<%namespace file="/search/index.mako" import="search_form"/>

<%def name="portlets()">
  ${blog_portlet()}
</%def>


${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text', 'tags'], target=url(controller='search', action='index'))}

${universities_section(c.unis, url(controller='profile', action='browse'))}
<br class="clear-left" />
