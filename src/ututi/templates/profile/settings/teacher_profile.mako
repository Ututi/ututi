<%inherit file="/profile/settings/teacher_base.mako" />
<%namespace name="profile" file="/profile/settings/profile.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  ${profile.head_tags()}
</%def>

<%def name="pagetitle()">${_("General information")}</%def>

${profile.form()}
