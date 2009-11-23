<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/group.mako" import="*"/>
<%namespace file="/portlets/universal.mako" import="*"/>
<%namespace file="/portlets/search.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="user_sidebar(exclude=[])">
<div id="sidebar">
  %if not 'search' in exclude:
  ${search_portlet(parts=['text'], target=url(controller='profile', action='search'))}
  %endif
  %if not 'blog' in exclude:
  ${blog_portlet()}
  %endif
  %if not 'files' in exclude:
  ${quick_file_upload_portlet(c.user.groups + c.user.watched_subjects, label='user_files')}
  %endif
  %if not 'create_subject' in exclude:
  ${user_create_subject_portlet()}
  %endif
  %if not 'recommend' in exclude:
  ${user_recommend_portlet()}
  %endif
  %if not 'gg' in exclude and h.check_crowds(['root']):
  ${user_gg_portlet()}
  %endif
  %if not 'groups' in exclude:
  ${user_groups_portlet()}
  %endif
  %if not 'banners' in exclude:
  ${ututi_banners_portlet()}
  %endif
</div>
</%def>

<%def name="group_sidebar(exclude=[])">
<div id="sidebar">
  %if not 'info' in exclude:
  ${group_info_portlet()}
  %endif
  %if not 'files' in exclude:
  ${quick_file_upload_portlet([c.group] + c.group.watched_subjects, label='group_files')}
  %endif
  %if not 'forum' in exclude:
  ${group_forum_post_portlet()}
  %endif
  %if not 'members' in exclude:
  ${group_invite_member_portlet()}
  %endif
  ${ututi_dalintis_portlet()}
  %if not 'subjects' in exclude:
  ${group_watched_subjects_portlet()}
  %endif
</div>
</%def>
