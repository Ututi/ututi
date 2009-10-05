<%inherit file="/base.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>
<%namespace file="/portlets/banners.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${ututi_join_portlet()}
  ${ututi_banners_portlet()}
</div>
</%def>



  <h1>${_('UTUTI - student information online')}</h1>
  <div id="ututi_features">
    <div id="can_find">
      <h3>${_('What can You find here?')}</h3>
      ${_('Group mailing lists, <a href="%(link)s" title="Subject list">subject</a> wikis, files, lecture notes and answers to questions that matter for your studies.') %\
        dict(link=url(controller='search', action='index', obj_type='subject'))|n}
    </div>
    <div id="can_do">
      <h3>${_('What can you do here?')}</h3>
      ${_('Store <a href="%(subjects)s" title="Subject list">study materials</a>\
      and pass them on for future generations, create\
      <a href="%(groups)s" title="Group list">academic groups</a>\
      and communicate with groupmates.') % dict(subjects=url(controller='search', action='index', obj_type='subject'),\
                                                groups=url(controller='search', action='index', obj_type='group'))|n}
    </div>
  </div>
  <div id="frontpage-search">
    <h1>${_('Ututi search')}</h1>

    ${search_form(parts=['obj_type', 'text'])}

  </div>

