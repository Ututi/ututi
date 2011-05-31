<%inherit file="/user/teacher_base.mako" />

%if c.teacher.publications:
  <div id="teacher-publications" class="wiki-page">
    ${h.html_cleanup(c.teacher.publications)}
  </div>
%else:
  ${_("%(teacher)s has not listed any publications.") % dict(teacher=c.teacher.fullname)}
%endif
