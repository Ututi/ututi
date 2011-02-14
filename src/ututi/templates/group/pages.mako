<%inherit file="/group/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="tabs, tooltip"/>

${tabs()}

<%def name="css()">
div.wiki-tekstas, div.wiki-tekstas-last {background-color: white;}
</%def>

<%def name="create_wiki_nag()">
<div id="page-intro">
<%self:rounded_block class_='subject-intro-block' id="subject-intro-block-pages">
  <h2 style="margin-top: 5px">${_('Create wiki documents')}</h2>
  <p>
    ${_('Collecting notes in Word? You can store your notes here, where they can be read and edited by your classmates.')}
  </p>
  <h2>${_('What can be a wiki document?')}</h2>
  <ul class="subject-intro-message">
    <li>${_('Shared notes')}</li>
    <li>${_('Personal notes written down during a meeting')}</li>
    <li>${_('Any text that you want to collaborate on with your coworkers')}</li>
  </ul>

  <div style="margin-top: 10px; margin-left: 20px">
    ${h.button_to(_('Create a wiki document'), url(controller='grouppage', action='add', id=c.group.group_id),
              method='GET')}
  </div>
</%self:rounded_block>
</div>
</%def>

%if c.group.n_pages():
  <%self:rounded_block class_='portletGroupFiles' id="subject_pages">
  <div class="GroupFiles GroupFilesWiki">
    <%
       if h.check_crowds(['moderator']):
         pages = c.group.pages
       else:
         pages = [page for page in c.group.pages if not page.isDeleted()]
       count = len(pages)
    %>
    <h2 class="portletTitle bold">${_("Group's Wiki Pages")} (${count})</h2>
    %if c.user:
    <span class="subject-but">
        ${h.button_to(_('Create a wiki document'), url(controller='grouppage', action='add', id=c.group.group_id, tags=c.group.location_path),
                  method='GET')}
    </span>
    %endif
  </div>
  % if pages:
    ## show teacher notes before the rest (python sort is stable)
    <% pages = sorted(pages, lambda x, y: int(y.original_version.created.is_teacher) - \
                                                    int(x.original_version.created.is_teacher)) %>

    % for n, page in enumerate(pages):
      % if not page.isDeleted() or h.check_crowds(['moderator']):
       <% teacher_class = 'teacher-content' if page.original_version.created.is_teacher else '' %>
       <div class="${teacher_class} ${'wiki-tekstas' if n < count else 'wiki-tekstas-last'}">
         <p>
            %if page.original_version.created.is_teacher:
              ${tooltip(_("Teacher's material"), img='/img/icons/teacher-cap.png')}
            %endif
           <span class="orange bold"><a href="${page.url('grouppage')}" title="${page.title}">${page.title}</a></span>
           <span class="grey verysmall">${h.fmt_dt(page.last_version.created_on)}</span>
           <span class="author verysmall"><a href="${page.last_version.created.url('grouppage')}">${page.last_version.created.fullname}</a></span>
         </p>
         <p>
           ${h.ellipsis(page.last_version.plain_text, 250)}
         </p>
       </div>
      % endif
    % endfor
  % else:
    <br />
    <span class="notice">${_('The group has no pages yet - create one!')}</span>
  % endif
  </%self:rounded_block>

%else:
  ${create_wiki_nag()}
%endif

