<%inherit file="/profile/home_base.mako" />
<%namespace file="/sections/standard_buttons.mako" import="close_button" />

<%def name="head_tags()">
${parent.head_tags()}
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
  });
</script>
</%def>

<%def name="teacher_unverified_nag()">
<%self:rounded_block id="teacher_unverified" class_="portletTeacherUnverified">
<div class="inner">
  <h2 class="portletTitle bold">${_('Welcome to Ututi!')}</h2>
  <div>
    ${_('At the moment You are not confirmed as a teacher. Our administrators have been notified and will verify You shortly.'
        ' Until then some restriction may apply to what You are allowed to do.')}
  </div>
</div>
</%self:rounded_block>
</%def>

<%def name="teach_course_nag()">
<%self:rounded_block id="user_location" class_="portletNewDalykas">
<div class="floatleft usergrupeleft">
  <h2 class="portletTitle bold">${_('Please specify the courses you are teaching')}</h2>
  <ul id="prosList">
    <li>${_('Get in touch with your students')}</li>
    <li>${_('Share course materials easily')}</li>
  </ul>
</div>
<div class="floatleft usergruperight">
  <form action="${url(controller='profile', action='teach_subjects')}" method="GET"
        style="float: none">
    <fieldset>
      <legend class="a11y">${_('Find courses I teach')}</legend>
      <label><button value="submit" class="btnMedium"><span>${_('find courses I teach')}</span></button>
      </label>
    </fieldset>
  </form>
  <div class="right_cross"><a id="hide_suggest_teach_course" href="">${_('no, thanks')}</a></div>
</div>
<br class="clear-left" />
<script type="text/javascript">
  //<![CDATA[
    $('#hide_suggest_teach_course').click(function() {
        $(this).closest('.portlet').hide();
        $.post('${url(controller='profile', action='js_hide_element')}',
               {type: 'suggest_teach_course'});
        return false;
    });
  //]]>
</script>
</%self:rounded_block>
</%def>

<%def name="subject_list(subjects)">
<div class="subject-description-list">
  <dl>
    %for n, subject in enumerate(subjects):
    <div class="subject-description ${'with-top-line' if n else ''}">
      ${close_button(url(controller='profile', action='unteach_subject', subject_id=subject.id), class_='unteach-button')}
      <div>
        <dt>
          <a href="${subject.url()}">${h.ellipsis(subject.title, 60)}</a>
        </dt>
        <dd class="tags">
          %for index, tag in enumerate(subject.location.hierarchy(True), 1):
            %if index != 1:
            | ## Separator
            %endif
            <a href="${tag.url()}" title="${tag.title}">${tag.title_short}</a>
          %endfor
        </dd>
      </div>
      <div style="margin-top: 5px">
        <span class="tiny-text">
          ${_('Add:')}
        </span>
        <dd class="files">
          ${_('Files:')} ${h.subject_file_count(subject.id)}
        </dd>
        <dd class="pages">
          ${_('Wiki pages:')} ${h.subject_page_count(subject.id)}
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

%if c.user.location is not None:
${self.location_updated()}
%else:
${self.location_nag(_('Tell us where you work'))}
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
        ${h.button_to(_('add courses'), url(controller='profile', action='teach_subjects'))}
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
%endif
