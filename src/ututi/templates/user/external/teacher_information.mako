<%inherit file="/user/external/teacher_base.mako" />

<%def name="pagetitle()">${_("General information")}</%def>

%if c.teacher.description:
  <div id="teacher-information" class="wiki-page">
    ${h.html_cleanup(c.teacher.description)}
  </div>
%else:
  <div id="no-description-block">
    <h2>${_("There is no information.")}</h2>
  </div>
%endif
