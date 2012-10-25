<%inherit file="/profile/settings_base.mako" />

<div class="explanation-post-header">
  <h2>${_('News feed settings')}</h2>
  <p class="tip">
    ${_('Select which events you want to show up on your wall.')}
  </p>
</div>

<%
labels = {
    'forum_post_created': _('Forum posts'),
    'private_message_sent': _('Private messages'),
    'group_started_watching_subject': _('New subjects watched by group'),
    'group_stopped_watching_subject': _('Subjects no longer watched by group'),
    'mailinglist_post_created': _('Mailing list posts'),
    'subject_modified': _('Changes in subjects'),
    'member_joined': _('New group members'),
    'member_left': _('People who left groups'),
    'file_uploaded': _('File uploads'),
    'page_modified': _('Changes in wiki pages'),
    'subject_created': _('New subjects'),
    'page_created': _('New wiki pages'),
    'sms_message_sent': _('SMS messages'),
    'grp_group_members': _('Group members'),
    'grp_page_events': _('Page changes'),
    'grp_group_watched_subjects': _('Watched group subjects'),
    'grp_subjects': _('Subject updates'),
    'moderated_post_created': _('Moderated posts'),
    'group_created': _('New groups'),
    'subject_wall_post': _('Subject discussions'),
    'location_wall_post': _('University discussions'),
}
%>

<%def name="form_item(item)">
  %if isinstance(item, dict):
  <div class="collection click2show">
    <div class="click expander"></div>
    <div class="form_item parent">
      <label for="${item['id']}">
        <input name="group" id="${item['id']}" type="checkbox" value="${item['id']}" class="checkbox parent" />
        ${labels.get(item['id'], item['id'])}
      </label>
    </div>

    <div class="children show">
      %for child in item['children']:
        ${form_item(child)}
      %endfor
    </div>
  </div>
  %else:
  <div class="form_item">
    <label for="${item}">
      <input name="events" id="${item}" type="checkbox" value="${item}" class="checkbox child" />
      ${labels.get(item, item)}
    </label>
  </div>
  %endif
</%def>

<form method="POST" action="${url(controller='profile', action='update_wall_settings')}" class="new-style-form" id="wall_settings_form">
%for key, item in c.event_types.items():
  ${form_item(item)}
%endfor
${h.input_submit('Save', class_='btnMedium')}
</form>

<script type="text/javascript">

$('#wall_settings_form .collection').each(function() {
    check_collection(this);
});

$('#wall_settings_form .collection input.parent').click(function() {
    checked = $(this).attr('checked');
    $('.children input', $(this).closest('.collection')).each(function() {
        $(this).attr('checked', checked);
    });
});

$('#wall_settings_form .collection input.child').click(function() {
    check_collection($(this).closest('.collection'));
});

function check_collection(collection) {
    /* check or uncheck parent according to state of collection */
    parent = $('input.parent', $(collection));
    all_checked = ($('.children input:checked', $(collection)).length == $('.children input', $(collection)).length);
    parent.attr('checked', all_checked);
}
</script>
