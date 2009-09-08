<%inherit file="/base.mako" />
<%namespace name="files" file="/sections/files.mako" />
<%namespace file="/portlets/subject.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>

<%def name="title()">
  ${c.subject.title}
</%def>

<%def name="head_tags()">
    ${parent.head_tags()}
   <%files:head_tags />
</%def>

<%def name="portlets()">
<div id="sidebar">
  ${subject_info_portlet()}
</div>
</%def>

<%files:file_browser obj="${c.subject}", title="${_('Subject files')}" />

<div id="subject_pages" class="section">
  <h2>${_('Pages')}</h2>
  <div class="container">
    <br/>
    <a class="btn" href="${url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path)}">
      <span>${_('New page')}</span>
    </a>
    % if c.subject.pages:
      % for page in c.subject.pages:
        ${page_extra(page)}
      % endfor
    % else:
      <br/>
      <span class="notice">${_('The subject has no pages yet - create one!')}</span>
    % endif
  </div>
</div>
