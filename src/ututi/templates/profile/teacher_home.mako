<%inherit file="/profile/home_base.mako" />
<%namespace file="/sections/standard_buttons.mako" import="close_button" />
<%namespace file="/sections/standard_blocks.mako" name="b" import="rounded_block, item_list"/>
<%namespace file="/sections/standard_objects.mako" import="group_listitem_teacherdashboard"/>

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

<%def name="teacher_unverified_nag()">
<%self:rounded_block id="teacher_unverified" class_="portletTeacherUnverified">
<div class="inner">
  <h2 class="portletTitle bold">${_('Welcome to Ututi!')}</h2>
  <div>
    ${_('You have not been confirmed as a teacher yet. Our administrators will verify you shortly.'
        'Until then, your profile rights may be limited.')}
  </div>
</div>
</%self:rounded_block>
</%def>

<%def name="teach_group_nag()">
<%b:rounded_block class_="standard-portlet with-shade icon-group-gray">
<div style="float:right">
  ${h.button_to(_('add groups'), url(controller='profile', action='add_student_group'), class_='btnMedium', method='GET')}
</div>
<h2>${_('My student groups')}</h2>
<p>${_("Add student groups that you teach to.")}</p>
<div style="clear:both"></div>
</%b:rounded_block>
</%def>

<%def name="teach_course_nag()">
<%b:rounded_block class_="standard-portlet with-shade icon-subject-orange">
<h2>${_('Add courses you teach')}</h2>
<p><strong>${_('Create subjects you teach, or find those that are already created:')}</strong></p>
<ul class="pros-list">
  <li>${_('Here you will be able to upload course material, and groups watching the subject will be notified automatically.')}</li>
  <li>${_('You will be able to send messages to groups watching the subject.')}</li>
  <li>${_('Some other killer argument: i.e. how did I live without Ututi all this time?')}</li>
</ul>
${h.button_to(_('add courses'), url(controller='subject', action='add'), class_='btnMedium', method='GET')}
</%b:rounded_block>
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
          <a href="${subject.url()}">${_("Upload file")}</a>
          (${h.subject_file_count(subject.id)})
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

%if not c.user.teacher_verified:
  ${teacher_unverified_nag()}
%endif

%if c.user.teacher_verified:
  <div id="subject_list">
    %if c.user.taught_subjects:
    <%self:rounded_block class_='portletGroupFiles'>
    <div class="GroupFiles GroupFilesDalykai">
      <h2 class="portletTitle bold">
        ${_('My courses')}
        ##<span class="right_arrow verysmall normal normal-font">
        ##  <a href="${url(controller='profile', action='notifications')}"> ${_('notification settings')}</a>
        ##</span>
      </h2>
      <span class="group-but">
        ${h.button_to(_('add courses'), url(controller='subject', action='add'))}
      </span>
    </div>
    <div>
      ${self.subject_list(c.user.taught_subjects)}
    </div>
    </%self:rounded_block>
    %elif 'suggest_teach_course' not in c.user.hidden_blocks_list:
    ${self.teach_course_nag()}
    %endif
  </div>

  <div id="groups_list">
    %if c.user.student_groups:
    <%b:item_list title="${_('Student groups')}" items="${c.user.student_groups}">
      <%def name="header_button()">
        ${h.button_to(_('Add a group'), url(controller='profile', action='add_student_group'), method='GET')}
      </%def>
      <%def name="row(item)">
        ${group_listitem_teacherdashboard(item)}
      </%def>
    </%b:item_list>
    %elif 'suggest_teach_group' not in c.user.hidden_blocks_list:
    ${self.teach_group_nag()}
    %endif
  </div>
%endif
