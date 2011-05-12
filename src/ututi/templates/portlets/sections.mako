<%namespace file="/portlets/user.mako" import="profile_portlet,
                                               user_menu_portlet"/>
<%namespace file="/portlets/group.mako" import="group_info_portlet, group_settings_portlet,
                                                group_invite_member_portlet, group_sms_portlet,
                                                group_members_portlet"/>

<%def name="group_sidebar(exclude=[])">
  ${profile_portlet()}
  ${user_menu_portlet()}
  %if not 'info' in exclude:
    ${group_info_portlet()}
  %endif
  %if not c.group.forum_is_public:
    %if not 'sms' in exclude and c.group.is_member(c.user):
      ${group_sms_portlet()}
    %endif
  %else:
    ${group_members_portlet()}
  %endif
</%def>

<%def name="group_right_sidebar(exclude=[])">
  ${group_invite_member_portlet()}
  ${group_members_portlet()}
  ${group_settings_portlet()}
##  %if not 'sms' in exclude and c.group.is_member(c.user):
##    ${group_sms_portlet()}
##  %endif
</%def>
