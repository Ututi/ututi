<%inherit file="/base.mako" />
<%namespace file="/portlets/subject.mako" import="subject_info_portlet,
     subject_follow_portlet, subject_teachers_portlet, subject_stats_portlet"/>
<%namespace file="/subject/base.mako" import="pre_content" />


<%def name="head_tags()">
  ${parent.head_tags()}
  %if getattr(c, 'page', None):
    <meta property="og:title" content="${c.page.title}"/>
    <meta property="og:url" content="${c.page.url(qualified=True)}"/>
  %endif
 </%def>

<%def name="portlets()">
  ${subject_info_portlet()}
  ${subject_follow_portlet()}
  ${subject_teachers_portlet()}
  ${subject_stats_portlet()}
</%def>

${pre_content()}

${next.body()}
