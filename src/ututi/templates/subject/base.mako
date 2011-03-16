<%inherit file="/ubase-two-sidebars.mako" />
<%namespace file="/portlets/subject.mako" import="subject_info_portlet,
    subject_follow_portlet, subject_teachers_portlet, subject_stats_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet, google_ads_portlet" />

<%def name="portlets()">
  ${subject_info_portlet()}
  ${subject_follow_portlet()}
  ${subject_teachers_portlet()}
  ${subject_stats_portlet()}
</%def>

<%def name="portlets_right()">
  ${share_portlet(c.subject, _("Share this subject:"))}
  ${google_ads_portlet()}
</%def>

${next.body()}
