<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  <meta property="og:title" content="${c.page.title}"/>
  <meta property="og:url" content="${c.page.url(qualified=True)}"/>
 </%def>

<%def name="portlets()">
<div id="sidebar">
  ${subject_info_portlet(c.subject)}
  ${subject_similar_subjects_portlet()}
  ${ututi_prizes_portlet()}
</div>
</%def>

${next.body()}
