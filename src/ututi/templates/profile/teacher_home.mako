<%inherit file="/profile/home_base.mako" />

<%def name="location_updated()">
<div class="my-faculty"><a href="${c.user.location.url()}">${_('Go to my department')}</a></div>
</%def>

<%def name="teacher_unverified_nag()">
<%self:rounded_block id="teacher_unverified" class_="portletTeacherUnverified">
<div class="inner">
  <h2 class="portletTitle bold">${_('Welcome to Ututi!')}</h2>
  <div>
    ${_('At the moment You are not confirmed as a teacher. Our administrators have been notified and will verify You shortly.'
        ' Until then some restriction may apply to what You are allowed to do.')}
  </div>
</div>
</%self:rounded_block>
</%def>


%if c.user.location is not None:
${self.location_updated()}
%else:
${self.location_nag()}
%endif

%if not c.user.teacher_verified:
  ${teacher_unverified_nag()}
%endif
