<%inherit file="/base.mako" />
<%namespace file="/group/base.mako" name="base" />


<%def name="title()">
  ${base.title()}
</%def>

<%def name="portlets()">
  ${base.portlets()}
</%def>

<%def name="css()">
   ${base.css()}
</%def>

${base.group_menu()}
${base.various_dialogs()}

${next.body()}
