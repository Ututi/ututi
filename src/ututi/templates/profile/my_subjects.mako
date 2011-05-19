<%inherit file="/profile/home_base.mako" />
<%namespace file="/sections/standard_objects.mako" import="subject_listitem" />

<%def name="pagetitle()">
${_('My subjects')}
</%def>

<%def name="css()">
.GroupFilesContent-line {
   background: white;
}

.portletGroupFiles.rounded-block .cbl,
.portletGroupFiles.rounded-block .cbr {
    background-image: url('/img/portlets_bg_white.png');
}

</%def>

<%def name="head_tags()">
${parent.head_tags()}
<script type="text/javascript">
  $(document).ready(function() {
    $('.unwatch-button').click(function() {
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

<%def name="subject_list(subjects)">
<div class="subject-description-list">
  <dl>
    %for n, subject in enumerate(subjects):
      ${subject_listitem(subject, n)}
    %endfor
  </dl>
</div>
</%def>

<%def name="subjects_block(subjects)">
  %if subjects:
  <%self:rounded_block class_='portletGroupFiles'>
  <div class="GroupFiles GroupFilesDalykai">
    <h2 class="portletTitle bold">
      ${_('Subjects')}
      <span class="right_arrow verysmall normal normal-font">
        <a href="${url(controller='profile', action='notification_settings')}"> ${_('notification settings')}</a>
      </span>
    </h2>
    <span class="group-but">
      ${h.button_to(_('add subject'), url(controller='profile', action='watch_subjects'))}
    </span>
  </div>
  <div class="GroupFilesContent-line">
    ${self.subject_list(subjects)}
  </div>
  </%self:rounded_block>
  %elif 'suggest_watch_subject' not in c.user.hidden_blocks_list:
  ${self.watch_subject_nag()}
  %endif
</%def>

<div id="subject_list">
  ${subjects_block(c.user.watched_subjects)}
</div>

%if c.user.memberships:
<div>
  <p>
    <label>
      <input type="checkbox" name="show_group_subjects" id="show_group_subjects" value="true">
      ${_('Show subjects from my groups')}
    </label>
  </p>
  <script type="text/javascript">
    //<![CDATA[
      $('#show_group_subjects').click(function() {
          if ($(this).attr('checked')) {
              $('#subject_list').load("${url(controller='profile', action='js_all_subjects')}");
              // TODO: show a progress indicator as this takes a while.
          } else {
              $('#subject_list').load("${url(controller='profile', action='js_my_subjects')}");
          }
      });
    //]]>
  </script>
</div>
%endif
