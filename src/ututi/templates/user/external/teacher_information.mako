<%inherit file="/user/external/teacher_base.mako" />

<%def name="pagetitle()">${_("General information")}</%def>

<%def name="actionlink()">
  <a href="${url(controller='profile', action='edit_information')}">
    ${_("edit")}
  </a>
</%def>

%if c.teacher.general_info.get_text():
  <div id="teacher-information" class="wiki-page">
    ${h.html_cleanup(c.teacher.general_info.get_text())}
  </div>
%else:
  ${_("%(teacher)s has not provided any information.") % dict(teacher=c.teacher.fullname)}
%endif
