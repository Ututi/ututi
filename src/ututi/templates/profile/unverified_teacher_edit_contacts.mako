<%inherit file="/profile/edit_contacts.mako" />
<%namespace name="edt" file="/profile/unverified_teacher_edit.mako" import="subheader, css"/>

<%def name="subheader()">
  ${edt.subheader()}
</%def>

<%def name="css()">
  ${edt.css()}
</%def>

${parent.body()}
