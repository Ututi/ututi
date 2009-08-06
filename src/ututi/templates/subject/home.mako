<%inherit file="/base.mako" />
<%namespace name="files" file="/sections/files.mako" />

<%def name="title()">
  ${c.subject.title}
</%def>

<%def name="head_tags()">
    ${parent.head_tags()}
   <%files:head_tags />
</%def>

<h1>${c.subject.title}</h1>

<div>
${c.subject.lecturer}
</div>

<%files:file_browser obj="${c.subject}" />

<div id="subject_pages">
  <h2>${_('Pages')}</h2>

  % if c.subject.pages:
    <ul>
    % for page in c.subject.pages:
      <li>
        ${h.link_to(page.title, url(controller='subjectpage', page_id=page.id, id=c.subject.subject_id, tags=c.subject.location_path))}
      </li>
    % endfor
    </ul>
  % endif
  ${h.link_to(_('Add page'), url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path))}
</div>
