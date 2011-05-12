<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/user.mako" import="profile_portlet,
  user_menu_portlet, user_groups_portlet, user_subjects_portlet,
  teacher_information_portlet" />

<%def name="portlets()">
%if c.user is not None:
  %if c.user.is_teacher:
    ${teacher_information_portlet()}
    ${user_menu_portlet()}
    ${user_groups_portlet()}
  %else:
    ${profile_portlet()}
    ${user_menu_portlet()}
    ${user_groups_portlet()}
    ${user_subjects_portlet()}
  %endif
%endif
</%def>

<%def name="css()">
${parent.css()}
%if c.user.is_teacher and not c.user.teacher_verified:
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

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title">${self.pagetitle()}</h1>
%endif

%if c.user.is_teacher and not c.user.teacher_verified:
  <%self:rounded_block id="unverified_teacher_block">
    <div class="content">
      <h2>${_('Welcome to Ututi!')}</h2>
      ${_('At the moment You are not confirmed as a teacher. Our administrators have been notified and will verify You shortly.'
          ' Please be patient. Meanwhile please tell us more about yourself.')}
    </div>
  </%self:rounded_block>
%endif

${next.body()}
