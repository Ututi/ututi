<%inherit file="/profile/edit_biography.mako" />
<%namespace name="edt" file="/profile/unverified_teacher_edit.mako" import="subheader, css"/>

<%def name="css()">
  ${edt.css()}
</%def>

<%def name="subheader()">
  ${edt.subheader()}
</%def>

${parent.body()}
