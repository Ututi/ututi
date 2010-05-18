<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>

<%namespace file="/anonymous_index/en.mako" import="*"/>

<%def name="portlets()">
  ${user_sidebar(['search'])}
</%def>


<h1>${_('Search')}</h1>
${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text', 'tags'], target=url(controller='profile', action='search'))}

${universities_section(c.unis, url(controller='profile', action='browse'))}
<br class="clear-left" />

