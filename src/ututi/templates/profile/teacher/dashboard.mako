<%inherit file="/profile/home_base.mako" />
<%namespace file="/sections/standard_buttons.mako" import="close_button" />
<%namespace file="/sections/standard_objects.mako" import="group_listitem_teacherdashboard"/>
<%namespace name="snippets" file="/sections/content_snippets.mako" />

<%def name="css()">
.group-description .sms-widget #sms_message {
    width: 420px;
}

.group-description .sms-widget .sms-box {
    background: transparent;
}

.send_sms_block {
    width: 450px;
    margin-top: 10px;
}

.browse-link {
    display: block;
    margin-top: 5px;
}

button.submit {
    margin-top: 10px;
}
</%def>

<%def name="pagetitle()">
  ${_("Dashboard")}
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.javascript_link('/javascript/teacher_dashboard.js')}
</%def>

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

<%def name="subject_list(subjects)">
<div class="section subjects">
  <div class="title">
    ${_("My courses:")}
    <span class="add-button">
      ${h.button_to(_('add courses'),
                    url(controller='subject', action='add'),
                    class_='dark add')}
    </span>
  </div>
  <div class="subject-description-list">
    <dl>
      %for n, subject in enumerate(subjects):
      <div class="u-object subject-description ${'with-top-line' if n else ''}">
        ${close_button(url(controller='profile', action='unteach_subject', subject_id=subject.id), class_='unteach-button')}
        <div>
          <dt>
            <a href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
          </dt>
        </div>
        <div style="margin-top: 5px">
          <dd class="settings">
            <a href="${subject.url(action='edit')}">${_("Settings")}</a>
          </dd>
          <dd class="feed">
            <a href="${subject.url(action='feed')}">${_("News feed")}</a>
          </dd>
          <dd class="files">
            <a href="${subject.url(action='files')}">${_("Files")}</a>
            (${h.item_file_count(subject.id)})
          </dd>
          <dd class="pages">
            <a href="${url(controller='subjectpage', action='add', id=subject.subject_id, tags=subject.location_path)}">${_("Wiki notes")}</a>
            (${h.subject_page_count(subject.id)})
          </dd>
        </div>
      </div>
      %endfor
    </dl>
  </div>
</div>
</%def>

<div id="teacher">
  %if c.user.taught_subjects:
    ${self.subject_list(c.user.taught_subjects)}
  %else:
  ${self.teach_course_nag()}
  %endif

  %if c.user.student_groups:
  <div class="section groups">
    <div class="title">
      ${_("Student groups")}
      <span class="add-button">
        ${h.button_to(_('add a group'), 
                      url(controller='profile', action='add_student_group'),
                      class_='dark add',
                      method='GET')}
      </span>
    </div>
    <div class="search-results-container">
      %for group in c.user.student_groups:
        ${group_listitem_teacherdashboard(group)}
      %endfor
    </div>
  </div>
  %else:
  ${self.teach_group_nag()}
  %endif
</div>
