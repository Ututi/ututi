<%inherit file="/user/teacher_base.mako" />

%if c.user_info.description:
  <div id="teacher-biography" class="wiki-page">
    ${h.html_cleanup(c.user_info.description)}
  </div>
%else:
  <div id="no-description-block">
    <h2>${_("There is no biography.")}</h2>
  </div>
%endif
