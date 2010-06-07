<%inherit file="/group/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>
<%namespace file="/group/base.mako" import="*"/>

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="portlets()">
  ${group_sidebar()}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/mailinglist.js')|n}
</%def>

${next.body()}
