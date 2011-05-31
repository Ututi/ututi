<%inherit file="/user/external/teacher_base.mako" />

<%def name="pagetitle()">${_("General information")}</%def>

%if c.teacher.description:
  <div id="teacher-information" class="wiki-page">
    ${h.html_cleanup(c.teacher.description)}
  </div>
%else:
  ${_("%(teacher)s has not provided any information.") % dict(teacher=c.teacher.fullname)}
%endif
