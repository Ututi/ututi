<%namespace file="/portlets/user.mako" import="user_information_portlet, user_groups_portlet, user_create_group_portlet,
                                               user_create_subject_portlet, user_recommend_portlet, user_support_portlet,
                                               teacher_information_portlet"/>
<%namespace file="/portlets/group.mako" import="group_info_portlet, group_forum_post_portlet,
                                                group_invite_member_portlet, group_sms_portlet,
                                                group_members_portlet"/>
<%namespace file="/portlets/universal.mako" import="quick_file_upload_portlet"/>
<%namespace file="/portlets/facebook.mako" import="facebook_likebox_portlet"/>
<%namespace file="/portlets/banners/base.mako" import="ubooks_portlet"/>
<%namespace file="/widgets/vote.mako" import="voting_bar, voting_widget" />
<%namespace file="/portlets/base.mako" import="uportlet" name="p"/>

<%def name="teacher_sidebar(exclude=[])">
<div id="sidebar">
  ${teacher_information_portlet()}
</div>
</%def>

<%def name="user_sidebar(exclude=[])">
%if c.user.is_teacher:
  ${teacher_sidebar(exclude)}
%else:
<div id="sidebar">
  ${user_information_portlet()}
  %if not 'files' in exclude:
  ${quick_file_upload_portlet(c.user.groups_uploadable + c.user.watched_subjects, label='user_files')}
  %endif
  %if not 'create_group' in exclude:
  ${user_create_group_portlet()}
  %endif
  %if not 'create_subject' in exclude:
  ${user_create_subject_portlet()}
  %endif
  %if not 'recommend' in exclude:
  ${user_recommend_portlet()}
  %endif
  ${user_groups_portlet()}
  <%p:uportlet id="voting_portlet" portlet_class="orange">
    <%def name="header()">
    ${_('Ututi voting is in progress!')}
    </%def>
    %if c.user.location is not None:
    <%
      count = c.user.location.vote_count_padded
      count_needed = 500 - count
    %>
    ${voting_bar(count, large=false)}
    <div style="clear: left; padding: 10px 0;">
    <strong>
    ${ungettext('Your university needs <strong>%(count)d more vote</strong>.', 'Your university needs <strong>%(count)d more votes.</strong>', count_needed) % dict(count=count_needed)|n}
    </strong>
    </div>
    %else:
    <a href="${url(controller='home', action='voting')}"><strong>${_('Vote for Your university!')}</strong></a>
    %endif
    <div class="right_arrow"><a href="${url(controller='home', action='voting')}">${_('find out more')}</a></div>
  </%p:uportlet>
</div>
%endif
</%def>

<%def name="group_sidebar(exclude=[])">
<div id="sidebar">
  %if not 'info' in exclude:
    ${group_info_portlet()}
  %endif
  %if not c.group.forum_is_public:
    %if not 'files' in exclude and c.group.has_file_area:
    ${quick_file_upload_portlet([c.group] + c.group.watched_subjects, label='group_files')}
    %endif
    %if not 'forum' in exclude:
    ${group_forum_post_portlet()}
    %endif
    %if not 'members' in exclude:
    ${group_invite_member_portlet()}
    %endif
    %if not 'sms' in exclude and c.group.is_member(c.user):
      ${group_sms_portlet()}
    %endif
    <div style="padding-top: 1em">
      ${ubooks_portlet()}
    </div>
  %else:
    ${group_members_portlet()}
    ${user_support_portlet()}
  %endif
</div>
</%def>
