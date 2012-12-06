<%namespace file="/portlets/user.mako" import="profile_portlet,
                                               user_menu_portlet"/>
<%namespace file="/portlets/group.mako" import="group_info_portlet, group_settings_portlet,
                                                group_invite_member_portlet, group_members_portlet"/>

<%def name="group_right_sidebar(exclude=[])">
  ${group_invite_member_portlet()}
  ${group_members_portlet()}
  ${group_settings_portlet()}
</%def>
