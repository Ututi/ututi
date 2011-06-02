<%inherit file="/user/external/teacher_base.mako" />

<%def name="pagetitle()">${_("Publications")}</%def>

<%def name="actionlink()">
  <a href="${url(controller='profile', action='edit_publications')}">
    ${_("edit")}
  </a>
</%def>

%if c.teacher.publications:
  <div id="teacher-publications" class="wiki-page">
    ${h.html_cleanup(c.teacher.publications)}
  </div>
%else:
  ${_("%(teacher)s has not listed any publications.") % dict(teacher=c.teacher.fullname)}
%endif
