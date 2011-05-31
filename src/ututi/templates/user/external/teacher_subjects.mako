<%inherit file="/user/teacher_base.mako" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<div class="page-section subjects">
  <div class="title">${_("Taught courses")}:</div>
  %if c.user_info.taught_subjects:
  <div class="search-results-container">
    %for subject in c.user_info.taught_subjects:
      ${snippets.subject(subject)}
    %endfor
  </div>
  %else:
    ${_("%(user_name)s doesn't teach any course.") % dict(user_name=c.user_info.fullname)}
  %endif
</div>
