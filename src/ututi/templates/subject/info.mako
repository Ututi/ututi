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
    </li>
    <li class="icon-teacher">
      ${c.subject.teacher_repr}
      %if c.user:
        <a href="${c.subject.url(action='edit')}">
          <img src="/img/icons.com/edit.png" alt="${_('Edit')}" />
        </a>
      %endif
    </li>
  </ul>
</div>

%if c.subject.description:
  <div class="wiki-page">
    ${h.html_cleanup(c.subject.description)}
  </div>
%else:
  <h2>${_("No description")}</h2>
  <p>${_("Add description to help your friends find this subject. You can also list main topics and references here.")}</p>
  ${h.button_to(_('Add description'), c.subject.url(action='edit'), class_='add')}
%endif
