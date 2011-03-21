<%inherit file="/ubase-sidebar.mako" />
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

${base.group_menu(show_info=getattr(c, 'show_info', False))}
${base.various_dialogs()}

${next.body()}
