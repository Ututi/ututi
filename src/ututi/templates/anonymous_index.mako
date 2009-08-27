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
  <ul id="ututi_info" class="bullets_large">
    <li>${_('What can You find here?')}<br/>
      <span class="small">${_('Mailing lists, academic groups, universities, file sharing.')}</span>
    </li>
    <li>${_('What can You do here?')}<br/>
      <span class="small">${_('Create lecture notes, keep Your study materials, upload and store files.')}</span>
    </li>
    <li>${_('Why here?')}<br/>
      <span class="small">${_("Because it's convenient.")}</span>
    </li>
    <li>${_('What is convenient?')}<br/>
      <span class="small">${_('Everything is in one place.')}</span>
    </li>
  </ul>

  <div id="frontpage-search">
    <h1>${_('Ututi search')}</h1>

    ${search_form()}

  </div>

