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

#groups_list div.large-header {
    background: #f6f6f6 url("/images/details/icon_group_25x25.png") 10px 6px no-repeat;
    padding-left: 35px;
}

#groups_list .inelement-form .formField label {
    float: left;
}

#groups_list .inelement-form textarea {
    margin: 5px 0 0;
}

#groups_list .inelement-form .formSubmit {
    clear: left;
    margin: 5px 0;
    float: none;
}

#groups_list .send_message_block {
    padding-left: 20px;
}

button.submit {
    margin-top: 10px;
}

</%def>

<%def name="pagetitle()">
  ${_("Home")}
</%def>

<%def name="head_tags()">
${parent.head_tags()}
  ${h.javascript_link('/javascript/teacher_dashboard.js')}
<script type="text/javascript">
  $(document).ready(function() {
    $('.unteach-button').click(function() {
      var actionurl = this.href + '&js=1';
      var container = $(this).closest('.subject-description');
      $.post(actionurl, function(status) {
        if (status == 'OK')
          container.slideUp('fast', function() {
            $(this).remove();
          });
      });
      return false;
    });

    $('.delete_group').click(function() {
        var answer = confirm("${_('Delete this group?')}");
        if (! answer) {
            return false;
        }
    });
  });
</script>
</%def>

<%def name="teach_group_nag()">
<div style="float:right">
  ${h.button_to(_('add groups'), url(controller='profile', action='add_student_group'), class_='btnMedium', method='GET')}
</div>
<h2>${_('My student groups')}</h2>
<p>${_("Add student groups that you teach to.")}</p>
<div style="clear:both"></div>
</%def>

<%def name="toaught_courses()">
  <div class="section subjects">
    <div class="title">
      ${_("My courses:")}
      <span class="add-button">${h.button_to(_('add courses'), url(controller='subject', action='add'))}</span>
    </div>
    <div>
      ${self.subject_list(c.user.taught_subjects)}
    </div>
  </div>
</%def>

<%def name="teach_course_nag()">
<h2>${_('Add courses you teach')}</h2>
<p><strong>${_('Create subjects you teach, or find those that are already created:')}</strong></p>
<ul class="pros-list">
  <li>${_('Here you will be able to upload course material, and groups studying the subject will be notified automatically.')}</li>
  <li>${_('All your course materials with be organized in one place.')}</li>
</ul>
${h.button_to(_('add courses'), url(controller='subject', action='add'), class_='btnMedium', method='GET')}
</%def>

<%def name="subject_list(subjects)">
<div class="subject-description-list">
  <dl>
    %for n, subject in enumerate(subjects):
    <div class="u-object subject-description ${'with-top-line' if n else ''}">
      ${close_button(url(controller='profile', action='unteach_subject', subject_id=subject.id), class_='unteach-button')}
      <div>
        <dt>
          <a href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
        </dt>
        <dd class="location-tags">
          %for index, tag in enumerate(subject.location.hierarchy(True), 1):
            %if index != 1:
            |
            %endif
            <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
          %endfor
        </dd>
      </div>
      <div style="margin-top: 5px">
        <span class="tiny-text" style="margin-right: 5px">
          ${_('Add:')}
        </span>
        <dd class="files">
          <a href="${subject.url()}/files">${_("Upload file")}</a>
          (${h.item_file_count(subject.id)})
        </dd>
        <dd class="pages">
          <a href="${url(controller='subjectpage', action='add', id=subject.subject_id, tags=subject.location_path)}">${_("Create wiki page")}</a>
          (${h.subject_page_count(subject.id)})
        </dd>
        <dd class="watch-count">
          <%
          user_count = subject.user_count()
          group_count = subject.group_count()
          %>
          ${_('The subject is watched by:')}
          ${ungettext("<span class='orange'>%(count)s</span> user",
                      "<span class='orange'>%(count)s</span> users",
                      user_count) % dict(count=user_count)|n}
          ${_('and')}
          ${ungettext("<span class='orange'>%(count)s</span> group",
                      "<span class='orange'>%(count)s</span> groups", 
                      group_count) % dict(count=group_count)|n}
        </dd>
      </div>
    </div>
    %endfor
  </dl>
</div>
</%def>

<div id="teacher">
%if c.user.teacher_verified:
    %if c.user.taught_subjects:
    ${self.toaught_courses()}
    %elif 'suggest_teach_course' not in c.user.hidden_blocks_list:
    ${self.teach_course_nag()}
    %endif

    %if c.user.student_groups:
    <div class="section groups">
      <div class="title">
        ${_("Student groups")}
        <span class="add-button">${h.button_to(_('add a group'), url(controller='profile', action='add_student_group'), method='GET')}</span>
      </div>
      <div class="search-results-container">
        %for group in c.user.student_groups:
          ${group_listitem_teacherdashboard(group)}
        %endfor
      </div>
    </div>
    %elif 'suggest_teach_group' not in c.user.hidden_blocks_list:
    ${self.teach_group_nag()}
    %endif
%endif
</div>
