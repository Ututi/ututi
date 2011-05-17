<%inherit file="/profile/edit_base.mako" />

<%def name="title()">
${c.user.fullname} &mdash; ${_("Account settings")}
</%def>

${next.body()}
