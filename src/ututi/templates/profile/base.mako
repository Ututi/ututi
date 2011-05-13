<%inherit file="/base.mako" />
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

%if hasattr(self, 'pagetitle'):
  <h1 class="page-title">${self.pagetitle()}</h1>
%endif

${next.body()}
