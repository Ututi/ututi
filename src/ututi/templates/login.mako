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


<h1>${_('Permission denied!')}</h1>

<img src="${url('/images/nope.png')}" />

<div>
${_('Only registered users can perform this action. Please log in, or register an account on our system.')}
</div>


<h2>Why should I join?</h2>
<hr />
<ul id="ututi_info" class="bullets_large">
  <li>${_('What can You find here?')}<br/>
    <span class="small">${_('Mailing lists, academic groups, universities, file sharing.')}</span>
  </li>
  <li>${_('What can You do here?')}<br/>
    <span class="small">${_('Create lecture notes, keep Your study materials, upload and store files.')}</span>
  </li>
</ul>

