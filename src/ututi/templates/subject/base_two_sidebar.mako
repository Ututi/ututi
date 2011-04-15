<%inherit file="/ubase-two-sidebars.mako" />

<%namespace file="/portlets/subject.mako" import="subject_followers_portlet, subject_related_subjects_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet" />
<%namespace file="/elements.mako" import="tabs" />
<%namespace name="base" file="/subject/base.mako" />

<%def name="head_tags()">
  ${base.head_tags()}
</%def>

<%def name="title()">${base.title()}</%def>

<%def name="portlets()">
  ${base.portlets()}
</%def>

<%def name="portlets_right()">
  ${share_portlet(c.subject, _("Share this subject:"))}
  ${subject_followers_portlet()}
  ${subject_related_subjects_portlet()}
</%def>

${base.pre_content()}

${next.body()}

