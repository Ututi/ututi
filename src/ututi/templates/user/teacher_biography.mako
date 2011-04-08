<%inherit file="/user/teacher_base.mako" />
<%namespace name="index" file="/user/index.mako" import="css" />

%if c.user.description:
  <div id="teacher-biography" class="wiki-page">
    ${h.html_cleanup(c.user.description)}
  </div>
%else:
  <div id="no-description-block">
  <h2>${_("No description")}</h2>
  <p>${_("Add description to help your friends find this subject. You can also list main topics and references here.")}</p>
  ${h.button_to(_('Add description'), c.user.url(action='edit'), class_='add')}
  </div>

%endif
