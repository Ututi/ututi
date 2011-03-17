<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/subject.mako" import="subject_info_portlet,
    subject_follow_portlet, subject_teachers_portlet, subject_stats_portlet"/>
<%namespace name="files" file="/sections/files.mako" />
<%namespace file="/sections/content_snippets.mako" import="tabs"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  <%files:head_tags />
  <meta property="og:title" content="${c.subject.title}"/>
  <meta property="og:url" content="${c.subject.url(qualified=True)}"/>
  %if c.subject.description:
  <meta property="og:description" content="${h.single_line(h.html_strip(c.subject.description))}"/>
  %endif
</%def>

<%def name="title()">${c.subject.title}</%def>

<%def name="portlets()">
  ${subject_info_portlet()}
  ${subject_follow_portlet()}
  ${subject_teachers_portlet()}
  ${subject_stats_portlet()}
</%def>

<h1 class="page-title">${c.subject.title}</h1>

%if c.subject.deleted:
<div id="note" style="margin-bottom: 25px; margin-top: 6px;">
  %if h.check_crowds(['moderator']):
  <div style="float: left;"><span class="message"><span>${_('Subject has been deleted, you can restore it if you want to.')}</span></span></div>
  <div style="float: left; margin-left: 6px;">
    ${h.button_to(_('Restore subject'), c.subject.url(action='undelete'))}
  </div>
  %else:
  <span class="message"><span>${_('Subject has been deleted, it will soon disappear from your watched subjects list.')}</span></span>
  %endif
  <br style="clear: left;" />
</div>
%endif

${tabs()}

${next.body()}
