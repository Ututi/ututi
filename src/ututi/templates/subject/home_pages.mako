<%inherit file="/subject/home.mako" />
<%namespace file="/sections/content_snippets.mako" import="*"/>
<%namespace name="files" file="/sections/files.mako" />

%if c.subject.n_pages():
  <%self:rounded_block class_='portletGroupFiles' id="subject_pages">
  <div class="GroupFiles GroupFilesWiki">
    <%
       count = len([page for page in c.subject.pages if not page.isDeleted()])
    %>
    <h2 class="portletTitle bold">${_("Subject's Wiki Pages")} (${count})</h2>
    %if c.user:
    <span class="group-but">
        ${h.button_to(_('Create a wiki document'), url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                  method='GET')}
    </span>
    %endif
  </div>
  % if c.subject.pages:
    % for n, page in enumerate(c.subject.pages):
      % if not page.isDeleted() or h.check_crowds(['moderator']):
       <div class="${'wiki-tekstas' if n < count - 1 else 'wiki-tekstas-last'}">
         <p><span class="orange bold"><a href="${page.url()}" title="${page.title}">${page.title}</a></span>
           <span class="grey verysmall"> ${h.fmt_dt(page.last_version.created_on)} </span>
           <span class="orange verysmall"><a href="${page.last_version.created.url()}">${page.last_version.created.fullname}</a></span>
         </p>
         <p>
           ${h.ellipsis(page.last_version.plain_text, 250)}
         </p>
       </div>
      % endif
    % endfor
  % else:
    <br />
    <span class="notice">${_('The subject has no pages yet - create one!')}</span>
  % endif
  </%self:rounded_block>

%else:

    <div id="page-intro" ${"style='display: none'" if blank_subject else ''}>

  <%self:rounded_block class_='subject-intro-block' id="subject-intro-block-pages">
    <h2 style="margin-top: 5px">${_('Create wiki documents')}</h2>
    <p>
      ${_('Collecting course notes in Word? Writing things down on a computer during lectures? You can store your notes here, where they can be read and edited by your classmates.')}
    </p>
    <h2>${_('What can be a wiki document?')}</h2>
    <ul class="subject-intro-message">
      <li>${_('Shared course notes')}</li>
      <li>${_('Personal course notes written down during a lecture')}</li>
      <li>${_('Any text that you want to collaborate on with your classmates')}</li>
    </ul>

    <div style="margin-top: 10px; margin-left: 20px">
      ${h.button_to(_('Create a wiki document'), url(controller='subjectpage', action='add', id=c.subject.subject_id, tags=c.subject.location_path),
                method='GET')}
    </div>
  </%self:rounded_block>

</div>

%endif
