<%inherit file="/user/external/teacher_base.mako" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<%def name="pagetitle()">${_("Teaching")}</%def>

<%def name="actionlink()">
  <a href="${url(controller='subject', action='add')}">
    ${_("add course")}
  </a>
</%def>

<div class="page-section subjects" id="taught-courses-list">
  <div class="title">${_("Taught courses")}:</div>
  %if c.teacher.taught_subjects:
  <div class="search-results-container">
    %for subject in c.teacher.taught_subjects:
      ${snippets.subject(subject)}
    %endfor
  </div>
  %else:
    ${_("%(teacher)s does not teach any course.") % dict(teacher=c.teacher.fullname)}
  %endif
</div>
