<%inherit file="/base.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
${h.stylesheet_link('/stylesheets/tagwidget.css')|n}
${h.stylesheet_link('/stylesheets/anonymous.css')|n}
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${ututi_join_portlet()}
</div>
</%def>



  <h1>${_('UTUTI - student information online')}</h1>
  <div id="ututi_features">
    <div id="can_find">
      <h3>${_('What can You find here?')}</h3>
      ${_('Group <em>forums</em>, subject <em>wikis</em>, <em>files</em>, lecture notes and <em>answers</em> to \
      questions that matter for your studies.')|n}
    </div>
    <div id="can_do">
      <h3>${_('What can you do here?')}</h3>
      ${_('Store <em>study materials</em> and pass them on for future generations, create <em>academic groups</em> \
      and communicate with groupmates.')|n}
    </div>
  </div>
  <div id="frontpage-search">
    <h1>${_('Ututi search')}</h1>

    ${search_form(parts=['obj_type', 'text'])}

  </div>

