<%inherit file="/profile/teacher/add_student_group.mako" />

<%def name="pagetitle()">${_('Edit a student group')}</%def>

<%def name="group_action_url()">${url(controller='profile', action='edit_student_group')}</%def>
