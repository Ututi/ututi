<%inherit file="/base.mako" />
<%namespace file="/portlets/sections.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/profile.css')|n}

${parent.head_tags()}
</%def>

<%def name="portlets()">
${user_sidebar()}
</%def>
