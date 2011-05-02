<%inherit file="/profile/settings/base.mako" />

<%doc>Adds unverified teacher info/warning block if needed.</%doc>

<%def name="css()">
${parent.css()}
%if not c.user.teacher_verified:
#unverified_teacher_block .content {
    padding-left: 70px;
    background: transparent url("/images/details/teacher.png") 10px center no-repeat;
}

#unverified_teacher_block h2 {
    font-weight: bold;
    font-size: 18px;
}
%endif
</%def>

<%def name="subheader()">
%if not c.user.teacher_verified:
  <%self:rounded_block id="unverified_teacher_block">
    <div class="content">
      <h2>${_('Welcome to Ututi!')}</h2>
      ${_('At the moment You are not confirmed as a teacher. Our administrators have been notified and will verify You shortly.'
          ' Please be patient. Meanwhile please tell us more about yourself.')}
    </div>
  </%self:rounded_block>
%else:
  ${parent.subheader()}
%endif
</%def>

${next.body()}
