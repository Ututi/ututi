<%inherit file="/user/teacher_base.mako" />

%if c.user_info.publications:
  <div id="teacher-publications" class="wiki-page">
    ${h.html_cleanup(c.user_info.publications)}
  </div>
%else:
  <div id="no-description-block">
    <h2>${_("This teacher has not listed any publications.")}</h2>
  </div>
%endif
