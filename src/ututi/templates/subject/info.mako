<%inherit file="/subject/base_two_sidebar.mako" />

<%def name="css()">
div#short-info-block {
    padding-bottom: 10px;
    margin-bottom: 10px;
    border-bottom: 1px solid #ff9900;
}
</%def>

<div id="short-info-block">
  <ul class="icon-list">
    <li class="icon-university">
      ${h.link_to(c.subject.location.title, c.subject.location.url())}
      %if not c.subject.teacher_repr and c.user:
        <a href="${c.subject.url(action='edit')}">
          <img src="${url('/img/icons.com/edit.png')}" alt="${_('Edit')}" />
        </a>
      %endif
    </li>
    %if c.subject.teacher_repr:
    <li class="icon-teacher">
      ${c.subject.teacher_repr}
      %if c.user and c.user_can_edit_settings:
        <a href="${c.subject.url(action='edit')}">
          <img src="${url('/img/icons.com/edit.png')}" alt="${_('Edit')}" />
        </a>
      %endif
    </li>
    %endif
  </ul>
</div>

%if c.subject.description:
  <div id="subject-description" class="wiki-page">
    ${h.html_cleanup(c.subject.description)}
  </div>
%else:
  <div id="no-description-block">
  <h2>${_("No description")}</h2>
  <p>${_("Add description to help your friends find this subject. You can also list main topics and references here.")}</p>
  ${h.button_to(_('Add description'), c.subject.url(action='edit'), class_='add')}
  </div>
%endif
