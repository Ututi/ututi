<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/portlets/banners/base.mako" import="*"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  %if getattr(c, 'page', None) and getattr(c, 'subject', None):
    <meta property="og:title" content="${c.page.title}"/>
    <meta property="og:url" content="${c.page.url(qualified=True)}"/>
  %elif getattr(c, 'page', None):
    <meta property="og:title" content="${c.page.title}"/>
    <meta property="og:url" content="${c.page.url('grouppage', qualified=True)}"/>
  %endif
 </%def>

<%def name="portlets()">
% if getattr(c,'subject', None):
<div id="sidebar">
  ${subject_info_portlet(c.subject)}
  ${subject_similar_subjects_portlet()}
  ${ubooks_portlet()}
</div>
% endif
</%def>

${next.body()}
