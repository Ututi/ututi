<%inherit file="/profile/base.mako" />
<%namespace file="/widgets/tags.mako" import="*"/>
<%namespace file="/search/index.mako" import="*"/>

<%def name="pagetitle()">${_('Search')}</%def>

${search_form(c.text, c.obj_type, c.tags, parts=['obj_type', 'text', 'tags'], target=url(controller='profile', action='search'), js_target=url(controller='profile', action='search_js'), js=True)}
${search_results(c.results, controller='profile', action='search_js')}
