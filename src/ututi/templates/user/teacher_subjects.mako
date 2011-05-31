<%inherit file="/user/teacher_base.mako" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<div class="page-section subjects">
  <div class="title">${_("Taught courses")}:</div>
  %if c.teacher.taught_subjects:
  <div class="search-results-container">
    %for subject in c.teacher.taught_subjects:
      ${snippets.subject(subject)}
    %endfor
  </div>
  %else:
    ${_("%(teacher_name)s doesn't teach any course.") % dict(teacher_name=c.teacher.fullname)}
  %endif
</div>
