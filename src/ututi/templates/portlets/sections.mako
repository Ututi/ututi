<%namespace file="/portlets/user.mako" import="profile_portlet, invite_friends_portlet,
                                               user_groups_portlet, user_subjects_portlet, teacher_information_portlet,
                                               user_menu_portlet, user_description_portlet, todo_portlet"/>
<%namespace file="/portlets/group.mako" import="group_info_portlet, group_settings_portlet,
                                                group_invite_member_portlet, group_sms_portlet,
                                                group_members_portlet"/>
<%namespace file="/portlets/universal.mako" import="quick_file_upload_portlet, users_online_portlet, about_portlet"/>
<%namespace file="/portlets/facebook.mako" import="facebook_likebox_portlet"/>
<%namespace file="/portlets/banners/base.mako" import="ubooks_portlet"/>

<%def name="teacher_sidebar(exclude=[])">
<div id="sidebar">
  ${teacher_information_portlet()}
  ${user_menu_portlet()}
  ${user_groups_portlet()}
</div>
</%def>

<%def name="user_sidebar(exclude=[])">
%if c.user is not None:
  %if c.user.is_teacher:
    ${teacher_sidebar(exclude)}
  %else:
    ${profile_portlet()}
    ${user_menu_portlet()}
    ${user_groups_portlet()}
    ${user_subjects_portlet()}
  %endif
%endif
</%def>

<%def name="user_right_sidebar(exclude=[])">
  ${about_portlet()}
  ${todo_portlet()}
  ${invite_friends_portlet()}
  ${users_online_portlet()}
</%def>

<%def name="group_sidebar(exclude=[])">
<div id="sidebar">
  ${profile_portlet()}
  ${user_menu_portlet()}
  %if not 'info' in exclude:
    ${group_info_portlet()}
  %endif
  %if not c.group.forum_is_public:
    %if not 'sms' in exclude and c.group.is_member(c.user):
      ${group_sms_portlet()}
    %endif
    <div style="padding-top: 1em">
      ${ubooks_portlet()}
    </div>
  %else:
    ${group_members_portlet()}
  %endif
</div>
</%def>

<%def name="group_right_sidebar(exclude=[])">
  ${group_invite_member_portlet()}
  ${group_members_portlet()}
  ${group_settings_portlet()}
##  %if not 'sms' in exclude and c.group.is_member(c.user):
##    ${group_sms_portlet()}
##  %endif
</%def>
