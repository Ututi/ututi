<%inherit file="/base.mako" />
<%namespace file="/portlets/subject.mako" import="subject_info_portlet,
    subject_follow_portlet, subject_teachers_portlet, subject_stats_portlet"/>
<%namespace name="files" file="/sections/files.mako" />
<%namespace file="/elements.mako" import="tabs"/>

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

<%def name="pre_content()">
%if hasattr(c, 'notabs'):
<h1 class="page-title underline">${c.subject.title}</h1>
%else:
<h1 class="page-title">${c.subject.title}</h1>
%endif

%if c.subject.deleted:
  %if h.check_crowds(['moderator']):
  <p>${_('Subject has been deleted, you can restore it if you want to.')}</p>
  ${h.button_to(_('Restore subject'), c.subject.url(action='undelete'))}
  %else:
  <p>${_('Subject has been deleted, it will soon disappear from your watched subjects list.')}</p>
  %endif
%endif

%if not hasattr(c, 'notabs'):
  %if c.user:
    <div class="above-tabs">
      <a class="settings-link" href="${c.subject.url(action='edit')}">${_("Edit Settings")}</a>
    </div>
  %endif

  ${tabs()}
%endif
</%def>

${pre_content()}

${next.body()}
