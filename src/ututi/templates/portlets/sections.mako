<%namespace file="/portlets/user.mako" import="*"/>
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
  ${user_file_upload_portlet()}
  %endif
  %if not 'create_subject' in exclude:
  ${user_create_subject_portlet()}
  %endif
  %if not 'recommend' in exclude:
  ${user_recommend_portlet()}
  %endif
  %if not 'groups' in exclude:
  ${user_groups_portlet()}
  %endif
  %if not 'banners' in exclude:
  ${ututi_banners_portlet()}
  %endif
</div>
</%def>
