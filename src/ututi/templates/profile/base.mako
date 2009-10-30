<%inherit file="/base.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/portlets/search.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="head_tags()">
${h.stylesheet_link('/stylesheets/profile.css')|n}

${parent.head_tags()}
</%def>


<%def name="portlets()">
<div id="sidebar">
  ${user_file_upload_portlet()}
  ${user_create_subject_portlet()}
  ${user_recommend_portlet()}
  ${search_portlet(parts=['text'], target=url(controller='profile', action='search'))}

  ${user_subjects_portlet()}
  ${user_groups_portlet()}
  ${ututi_links_portlet()}
  ${ututi_banners_portlet()}
</div>
</%def>
