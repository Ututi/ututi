<%inherit file="/profile/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>

<%namespace file="/anonymous_index.mako" import="*"/>

<%def name="portlets()">
  ${user_sidebar(['search'])}
</%def>


<%def name="pagetitle()">
${_('Search')}
</%def>
${search_form(c.text, c.obj_type, c.tags, parts=['text'], target=url(controller='profile', action='search'))}

<br class="clear-left" />

