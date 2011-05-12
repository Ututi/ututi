<%inherit file="/profile/edit_base.mako" />

<%def name="css()">
${parent.css()}
.select-interval-form {
    float: right;
    color: #999;
    font-size: 11px;
    padding-right: 20px;
}
.select-interval-form.done {
    background: url('/img/icons.com/ok.png') no-repeat right center;
}
.select-interval-form.progress {
    background: url('/images/details/icon_progress.gif') no-repeat right center;
}
.select-interval-form select {
    width: auto;
}
.notification-block {
    margin-top: 15px;
}
.notification-block .header {
    border-bottom: 1px solid #f90;
    padding: 5px 0px 5px 20px;
}
.notification-block.subject .header {
    background: url('/img/icons.com/subject_medium_grey.png') no-repeat left center;
}
.notification-block.group .header {
    background: url('/img/icons.com/group_medium_grey.png') no-repeat left center;
}
.notification-block.email .header {
    background: url('/img/icons.com/email_medium_grey.png') no-repeat left center;
}
.notification-block .warning {
    font-size: 11px;
    color: #990000;
    display: none;
}
.notification-block .show-warning .warning {
    display: inline;
}
.checkbox-list {
    padding: 5px 5px 5px 20px;
}
.checkbox-list form {
    padding: 2px 0;
}
.checkbox-list form input {
    margin-right: 2px;
}
.post-header {
    margin-top: 30px;
}
</%def>


<%def name="head_tags()">
${parent.head_tags()}

<script type="text/javascript">
    $(document).ready(function(){
        // action checkboxes
        $('.action-checkbox').change(function() {
            var url;
            if ($(this).is(':checked'))
                url = $(this).closest('form').find('.check-url').val();
            else
                url = $(this).closest('form').find('.uncheck-url').val();
            // call AJAX action (TODO: handle ajax failures and quickclicks)
            $.get(url);
        });

        // some more control for watch/unwatch checkboxes
        $('.watch.action-checkbox').change(function() {
            if ($(this).is(':checked'))
                $(this).closest('form').removeClass('show-warning');
            else
                $(this).closest('form').addClass('show-warning');
        });

        // select interval forms
        $('.select-interval-form button').hide();
        $('.select-interval-form select').change(function (event) {
            var url = event.target.form.action;
            $(event.target.form).removeClass('done').addClass('progress');
            $.get(
                url,
                {'each': event.target.value, 'ajax': 'yes'},
                function() { $(event.target.form).removeClass('progress').addClass('done'); }
            );
        });
    });
</script>
</%def>

<%def name="pagetitle()">${_('Email notification settings')}</%def>

<div class="post-header">
  <p style="font-size: 14px; margin-bottom: 0">
    ${_('Email me when')}
  </p>
  <div class="tip">
    ${_('What notifications would you like to receive by email:')}
  </div>
</div>

<%def name="notification_interval_form(action_url, selected)">
    <% notification_options = [('hour', _('immediately')),
                               ('day', _('at the end of the day')),
                               ('never', _('never'))] %>
    <form class="select-interval-form" action="${action_url}">
      <label>
        ${_('Send me email:')}
        ${h.select('each', [selected], notification_options)}
      </label>
      ${h.input_submit(_('Confirm'), class_='dark inline')}
    </form>
</%def>

<div class="subject notification-block">
  <div class="header">
    <strong>${_("Personally watched subjects' notifications")}</strong>
    ${notification_interval_form(url(controller='profile', action='set_receive_email_each'), c.user.receive_email_each)}
  </div>

  %if c.subjects:
    <div class="checkbox-list">
    %for subject in c.subjects:
      <form>
        <input type="hidden" class="check-url" value="${url(controller='profile', action='watch_subject', subject_id=subject.id, js=True)}" />
        <input type="hidden" class="uncheck-url" value="${url(controller='profile', action='unwatch_subject', subject_id=subject.id, js=True)}" />
        <label><input type="checkbox" class="watch action-checkbox" checked="checked" />${subject.title}</label>
        <span class="warning">${_("This subject will be removed from followed subject list.")}</span>
      </form>
    %endfor
    </div>
  %else:
    <p class="empty-note">${_('You do not follow any subjects.')}</p>
  %endif
</div>

%for group in c.groups:
<div class="group notification-block">
  <div class="header">
    <strong>${h.literal(_("Group's %(group_title)s notifications") % dict(group_title=h.link_to(group.title, group.url())))}</strong>
    ${notification_interval_form(group.url(action='set_receive_email_each'), group.is_member(c.user).receive_email_each)}
  </div>

  %if group.watched_subjects:
    <div class="checkbox-list">
    %for subject in group.watched_subjects:
      <form>
        <input type="hidden" class="check-url" value="${url(controller='profile', action='js_unignore_subject', subject_id=subject.id)}" />
        <input type="hidden" class="uncheck-url" value="${url(controller='profile', action='js_ignore_subject', subject_id=subject.id)}" />
        <% checked = 'checked="checked"' if subject not in c.user.ignored_subjects else '' %>
        <label><input type="checkbox" class="action-checkbox" ${checked} />${subject.title}</label>
      </form>
    %endfor
    </div>
  %else:
    <p class="empty-note">${_('This group does not follow any subjects.')}</p>
  %endif
</div>
%endfor

%if c.groups:
<div class="email notification-block">
  <div class="header">
    <strong>${_("Group emails")}</strong>
  </div>

  <div class="checkbox-list">
  %for group in c.groups:
    <form>
      <input type="hidden" class="check-url" value="${group.url(action='subscribe', js=True)}" />
      <input type="hidden" class="uncheck-url" value="${group.url(action='unsubscribe', js=True)}" />
      <% checked = 'checked="checked"' if group.is_subscribed(c.user) else '' %>
      <label><input type="checkbox" class="action-checkbox" ${checked} />${group.title}</label>
    </form>
  %endfor
  </div>
</div>
%endif
