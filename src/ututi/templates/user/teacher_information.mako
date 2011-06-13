<%inherit file="/user/teacher_base.mako" />

%if c.teacher.general_info.get_text():
  <div id="teacher-information" class="wiki-page">
    ${h.html_cleanup(c.teacher.general_info.get_text())}
  </div>
%else:
  ${_("%(teacher)s has not provided any information.") % dict(teacher=c.teacher.fullname)}
%endif
