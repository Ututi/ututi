<%inherit file="/profile/base.mako" />
<%namespace file="/elements.mako" import="tabs" />

<%def name="title()">
${c.user.fullname}
</%def>

<%def name="pagetitle()">${_("Edit your profile")}</%def>

<%def name="css()">
${parent.css()}
#back-to-home-page {
  display: block;
  margin-bottom: 10px;
}
.explanation-post-header {
    margin: 30px 0 15px;
}
</%def>

<div class="above-tabs">
  <a class="back-link" href="${url(controller='profile', action='home')}">${_('back')}</a>
</div>

${tabs()}

${next.body()}
