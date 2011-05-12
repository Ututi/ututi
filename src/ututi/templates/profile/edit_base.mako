<%inherit file="/profile/base.mako" />
<%namespace file="/elements.mako" import="tabs" />

<%def name="title()">
${c.user.fullname}
</%def>

<%def name="css()">
${parent.css()}
#back-to-home-page {
  display: block;
  margin-bottom: 10px;
}
</%def>

## subheader is actually a placeholder to put in
## a notification block for unverified teachers.
<%def name="subheader()">
  <div class="above-tabs">
    <a class="back-link" href="${url(controller='profile', action='home')}">${_('back')}</a>
  </div>
</%def>

${self.subheader()}

${tabs()}

${next.body()}
