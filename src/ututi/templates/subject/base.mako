<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/subject.mako" import="subject_info_portlet,
    subject_follow_portlet, subject_teachers_portlet, subject_stats_portlet"/>

<%def name="portlets()">
  ${subject_info_portlet()}
  ${subject_follow_portlet()}
  ${subject_teachers_portlet()}
  ${subject_stats_portlet()}
</%def>

${next.body()}
