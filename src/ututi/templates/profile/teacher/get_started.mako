<%inherit file="/profile/get_started_base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>
<%namespace name="location" file="/widgets/ulocationtag.mako" />

<%def name="css()">
${parent.css()}
#view-page-link {
  float: right;
}
#subject-features {
  max-width: 220px;
}
#subject-search-form input {
  width: 200px;
}
button#add-student-group {
  font-weight: normal;
}
</%def>

<% done = h.teacher_done_items(c.user) %>

<div class="steps">
  <div class="step ${'complete' if 'profile' in done else ''}">
    <div class="heading">
      <span class="number">1</span>
      <span class="title">${_("Fill your profile information")}</span>
    </div>
    <div class="content">
      <p>${_("Tell some basic information about yourself by editing your profile.")}</p>
      ${h.button_to(_("Edit profile"), url(controller='profile', action='edit'),
                    method='GET', class_='dark edit')}
    </div>
  </div>
  <div class="step clearfix ${'complete' if 'subject' in done else ''}">
    <div class="heading">
      <span class="number">2</span>
      <span class="title">${_("Create your subjects")}</span>
    </div>
    <%b:title_box title="${_('Features:')}" id="subject-features" class_="side-box">
      <ul class="feature-list small">
        <li class="file">${_("Upload course material")}</li>
        <li class="wiki">${_("Edit subject notes")}</li>
        <li class="notifications">${_("Notify your students")}</li>
        <li class="discussions">${_("Discuss the subject")}</li>
      </ul>
    </%b:title_box>
    <div class="content">
      <p>${_("Find subjects that your teach or create them.")}</p>
      <form id="subject-search-form" action="${url(controller='subject', action='lookup')}" method="POST">
        <input type="text" name="title" />
        ${location.hidden_fields(c.user.location)}
        ${h.input_submit(_('Create'), '', class_='inline')}
      </form>
    </div>
  </div>
  <div class="step ${'complete' if 'biography' in done else ''}">
    <div class="heading">
      <span class="number">3</span>
      <span class="title">${_("Complete your profile page")}</span>
    </div>
    <div class="content">
      <p>
        ${_("Ututi provides you a profile page that other people can access online. "
            "To have a complete page, please tell us some bits about your biography and your research interests.")}
      </p>
      <a class="forward-link" id="view-page-link" href="${c.user.url()}">
        ${_("View profile page")}
      </a>
      ${h.button_to(_("Add biography"), url(controller='profile', action='edit_biography'),
                    method='GET', class_='dark add inline')}
    </div>
  </div>
  <div class="step ${'complete' if 'group' in done else ''}">
    <div class="heading">
      <span class="number">4</span>
      <span class="title">${_("Add your student groups")}</span>
    </div>
    <div class="content">
      <p>${_("Ututi will keep track of your student groups and make it easy to reach them.")}</p>
      ${h.button_to(_('Add student group'), url(controller='profile', action='add_student_group'),
        class_='add inline', method='GET', id='add-student-group')}
    </div>
  </div>
</div>
