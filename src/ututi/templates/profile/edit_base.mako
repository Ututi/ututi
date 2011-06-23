<%inherit file="/profile/base.mako" />
<%namespace file="/elements.mako" import="tabs" />

<%def name="title()">
${c.user.fullname}
</%def>

<%def name="pagetitle()">
%if c.user.is_teacher:
${_("Edit your page")}
%else:
${_("Edit your profile")}
%endif
</%def>

<%def name="css()">
${parent.css()}
#back-to-home-page {
  display: block;
  margin-bottom: 10px;
}
</%def>

<div class="above-tabs">
%if c.user.is_teacher:
  <a class="forward-link" href="${c.user.url(action='external_teacher_index')}">${_('show my page')}</a>
%else:
  <a class="back-link" href="${url(controller='profile', action='home')}">${_('back')}</a>
%endif
</div>

${tabs()}

${next.body()}
