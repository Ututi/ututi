<%inherit file="/profile/get_started_base.mako" />
<%namespace file="/sections/standard_buttons.mako" import="close_button" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>
<%namespace name="location" file="/widgets/ulocationtag.mako" />
<%namespace file="/widgets/sms.mako" import="sms_widget" />
<%namespace name="elements" file="/elements.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
  <script type="text/javascript">
  $(document).ready(function() {
      $('.group-description .action-link').click(function() {
          var group = $(this).closest('.group-description')
          $('.action-block:visible').slideUp('fast');
          if ($(this).hasClass('email'))
              group.find('.email.action-block:hidden').slideDown('fast');
          else if ($(this).hasClass('sms'))
              group.find('.sms.action-block:hidden').slideDown('fast');
          return false;
      });
  });
  </script>
</%def>

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
.group-description .action-reply {
    display: none;
}

.group-description .action-block {
    display: none;
}

.group-description .email.action-block {
    margin-top: 15px;
}

.group-description .sms-widget #sms_message {
    width: 100%;
}

.group-description .sms-widget .sms-box {
    background: transparent;
}

button.submit {
    margin-top: 10px;
}

.sms-widget .sms-box {
    width: 300px;
}

.sms-widget button.submit {
    margin-top: 0px;
}

.browse-link {
    display: block;
    margin-top: 5px;
}
</%def>

<%def name="pagetitle()">
  ${_("Dashboard")}
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
<%def name="teach_group_nag()">
  <div class="feature-box one-column icon-group">
    <div class="title">
      ${_('Students groups that you teach to')}
    </div>
    <div class="clearfix">
      <div class="feature icon-email">
        ${h.literal(_("Easy way to contact your groups by sending a <strong>group message</strong>."))}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Add students groups'), url(controller='profile', action='add_student_group'), class_='add', method='GET')}
    </div>
  </div>
</%def>

<%def name="teach_course_nag()">
  <div class="feature-box one-column icon-subject">
    <div class="title">
      ${_("Add courses you teach")}
    </div>
    <div class="clearfix">
      <div class="feature icon-file-upload">
        <strong>${_("Files upload")}</strong> &ndash; ${_("You will be able to upload course material, that will be accessable for everyone, who is following your course.")}
      </div>
      <div class="feature icon-discussions">
        <strong>${_("Course discussions")}</strong> &ndash; ${_("Discuss course material and related subjects with your students.")}
      </div>
      <div class="feature icon-notifications">
        <strong>${_("Automatic notifications")}</strong> &ndash; ${_("Ututi will automaticaly inform students and groups about changes in course material.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Add your courses'), url(controller='subject', action='add'), class_='add', method='GET')}
      ${h.link_to(_("Or browse subjects' catalog"), c.user.location.url(action='catalog', obj_type='subject'), class_='browse-link')}
    </div>
  </div>
</%def>

<%def name="group_entry(group, first)">
<div class="u-object group-description ${'with-top-line' if not first else ''}">
  <form class="close-button" method="POST" action="${url(controller='profile', action='delete_student_group')}">
    <div>
      <input type="hidden" name="group_id" value="${group.id}" class="event_type"/>
      <input type="image" src="/img/icons.com/close.png" title="${_('Delete this group')}" class="delete_group" name="delete_group_${group.id}"/>
    </div>
  </form>
  <div>
    <div class="group-title">
      <dt> ${group.title} </dt>
      <dd class="group-email" style="margin-right: 10px"> ${group.email} </dd>
      %if group.group:
        ${elements.location_links(group.group.location)}
      %endif
    </div>
  </div>

  <div class="group-actions">
      <dd class="settings">
        <a href="${url(controller='profile', action='edit_student_group', id=group.id)}" >
          ${_('Edit group')}
        </a>
      </dd>
      <dd class="email">
        <a href="#" title="${_('Send message')}" class="email action-link">
          ${_('Send message')}
        </a>
      </dd>
      %if group.group is not None:
      <dd class="sms">
        <a href="#" title="${_('Send SMS')}" class="sms action-link">
          ${_('Send SMS')}
        </a>
      </dd>
      %endif
  </div>

  <div class="email action-block">
    <form method="POST" action="${url(controller='profile', action='studentgroup_send_message', id=group.id)}" class="inelement-form group-message-form" enctype="multipart/form-data">
      ${h.input_line('subject', _('Message subject:'), class_='message_subject wide-input')}
      <div class="formField">
        <textarea name="message" class="message" rows="5" rows="50"></textarea>
      </div>
      <div class="formField">
        <label for="file">
          <span class="labelText">${_('Attachment:')}</span>
          <input type="file" name="file" />
        </label>
      </div>
      <div class="formSubmit">
        ${h.input_submit(_('Send'), class_="btn message-send")}
      </div>
      <br class="clear-right" />
    </form>
  </div>
  <div class="message-sent action-reply">
    ${_('Your message was successfully sent.')}
  </div>
  %if group.group is not None:
  <div class="sms action-block">
    ${sms_widget(user=c.user, group=group.group, text='', parts=[])}
  </div>
  <div class="sms-sent action-reply">
    ${_('Your SMS was successfully sent.')}
  </div>
  %endif
</div>
</%def>

<%def name="subject_entry(subject, first=False)">
<div class="u-object subject-description ${'with-top-line' if not first else ''}">
  ${close_button(url(controller='profile', action='unteach_subject', subject_id=subject.id), class_='unteach-button')}
  <div>
    <dt>
      <a href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
    </dt>
    ${elements.location_links(subject.location)}
  </div>
  <div style="margin-top: 5px">
    <dd class="settings">
      <a href="${subject.url(action='edit')}">${_("Settings")}</a>
    </dd>
    <dd class="feed">
      <a href="${subject.url(action='feed')}">${_("Discussions")}</a>
    </dd>
    <dd class="files">
      <a href="${subject.url(action='files')}">${_("Files")}</a>
      (${h.item_file_count(subject.id)})
    </dd>
    <dd class="pages">
      <a href="${subject.url(action='pages')}">${_("Wiki notes")}</a>
      (${h.subject_page_count(subject.id)})
    </dd>
  </div>
</div>
</%def>

<%def name="subject_section(subjects)">
<div class="section subjects">
  <div class="title">
    ${_("My courses:")}
    <span class="action-button">
      ${h.button_to(_('add courses'),
                    url(controller='subject', action='add'),
                    class_='dark add')}
    </span>
  </div>
  <div class="subject-description-list">
    <dl>
      %for n, subject in enumerate(subjects):
        ${subject_entry(subject, n == 0)}
      %endfor
    </dl>
  </div>
</div>
</%def>

<%def name="group_section(groups)">
<div class="section groups">
  <div class="title">
    ${_("Student groups")}
    <span class="action-button">
      ${h.button_to(_('add a group'), 
                    url(controller='profile', action='add_student_group'),
                    class_='dark add',
                    method='GET')}
    </span>
  </div>
  <div class="group-description-list">
    <dl>
      %for n, group in enumerate(groups):
        ${group_entry(group, n == 0)}
      %endfor
    </dl>
  </div>
</div>
</%def>

%if c.user.taught_subjects:
  ${subject_section(c.user.taught_subjects)}
%else:
  ${self.teach_course_nag()}
%endif

%if c.user.student_groups:
  ${group_section(c.user.student_groups)}
%else:
  ${self.teach_group_nag()}
%endif
