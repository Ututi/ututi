<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>

<%def name="subject_info_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  %if subject.description:
  <%self:portlet id="subject-information-portlet">
    <%def name="header()">
      ${_('Info')}
    </%def>
    <div class="description">
      ${h.html_cleanup(subject.description)}
    </div>
    %if c.user:
      <a href="${subject.url(action='edit')}" id="description-edit-link">
        <img src="/img/icons.com/edit.png" alt="${_('Edit')}" />
      </a>
    %endif
  </%self:portlet>
  %endif
</%def>

<%def name="subject_follow_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  %if c.user is not None:
    <%self:portlet id="subject-follow-portlet">
      %if c.user.watches(subject):
        ${h.button_to(_("Unfollow"), subject.url(action='watch'), class_='dark', method='GET')}
      %else:
        ${h.button_to(_("Follow"), subject.url(action='watch'), class_='dark add', method='GET')}
      %endif
    </%self:portlet>
  %endif
</%def>

<%def name="subject_teachers_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  <%self:portlet id="subject-teachers-portlet">
    <ul class="icon-list">
      <li class="icon-university align-top">
        %if subject.location.parent is None:
          ${_("University:")}
        %else:
          ${_("Faculty / department:")}
        %endif
        <br />
        ${h.link_to(subject.location.title, subject.location.url())}
      </li>
      <li class="icon-teacher align-top">
        %if subject.teachers:
          <% teacher_list = ', '.join([h.link_to(teacher.fullname, teacher.url())
                                       for teacher in subject.teachers]) %>
          ${ungettext('Lecturer:', 'Lecturers:', len(subject.teachers))}
          <br />
          ${h.literal(teacher_list)}
        %elif subject.lecturer:
          ${_('Lecturer:')}
          <br />
          ${subject.lecturer}
        %endif
      </li>
    </ul>
  </%self:portlet>
</%def>


<%def name="subject_stats_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  <%self:portlet id="subject-statistics-portlet">
    ${_("Files and wiki notes:")}
    <ul class="icon-list statistics">
      <li class="icon-file">${len(subject.files)}</li>
      <li class="icon-note">${len(subject.pages)}</li>
    </ul>

    ${_("Followers:")}
    <ul class="icon-list statistics">
      <li class="icon-group">${subject.group_count()}</li>
      <li class="icon-user">${subject.user_count()}</li>
    </ul>

    ${_("Subject rating:")}
    ${h.image('/img/icons.com/rating-%d.png' % subject.rating(), alt=str(subject.rating()))}
  </%self:portlet>
</%def>

<%def name="subject_similar_subjects_portlet()">
  %if c.similar_subjects:
  <%self:uportlet id="similar_subjects_portlet">
    <%def name="header()">
      ${_('Similar subjects')}
    </%def>
      <ul class="Dalykail">
        <%
           count_subjects = len(c.similar_subjects)
        %>
        %for index, item in enumerate(c.similar_subjects):
                <li${index==count_subjects-1 and " class='Dalykail-last'" or ''}>
                  <dl>
            <%
               location = item['hierarchy']
            %>

                        <dt><a ${h.trackEvent(None, 'similar_subjects', 'subject','subject')} href="${item['url']}">${item['title']}</a></dt>
            %for n, tag in enumerate(location):
              <dd class="s-line"><a class="uni" href="${tag['url']}" title="${tag['title']}">${tag['title_short']}</a></dd>
              %if n != len(location) -1:
                <dd class="s-line">|</dd>
              %endif
            %endfor
            %if item['lecturer']:
              <dd class="s-line">${_('Lect.')} ${item['lecturer']}</dd>
            %endif
                        <dt></dt>
            <%
                file_cnt = item['file_cnt']
                page_cnt = item['page_cnt']
                group_cnt = item['group_cnt']
                user_cnt = item['user_cnt']
             %>
            <dd class="files">${ungettext('%(count)s <span class="a11y">file</span>', '%(count)s <span class="a11y">files</span>', file_cnt) % dict(count=file_cnt)|n}</dd>
            <dd class="pages">${ungettext('%(count)s <span class="a11y">wiki page</span>', '%(count)s <span class="a11y">wiki pages</span>', page_cnt) % dict(count=page_cnt)|n}</dd>
            <dd class="watchedBy"><span class="a11y">${_('Watched by:')}</span>
              ${ungettext("%(count)s group", "%(count)s groups", group_cnt) % dict(count=group_cnt)|n}
              ${_('and')}
              ${ungettext("%(count)s member", "%(count)s members", user_cnt) % dict(count=user_cnt)|n}
            </dd>
                  </dl>
                </li>
        %endfor
          </ul>
  </%self:uportlet>
  %endif
</%def>
