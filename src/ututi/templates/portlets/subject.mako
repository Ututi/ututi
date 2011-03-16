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

<%def name="old_subject_info_portlet(subject=None)">
  <%
     if subject is None:
         subject = c.subject
  %>

  <%self:uportlet id="subject_info_portlet" portlet_class="first">
    <%def name="header()">
      ${_('Subject information')}
    </%def>
    <div class="dalyko-info">
        <h2 class="group-name">${subject.title}</h2>
    </div>
    <div class="dalyko-info">
        <p>
          <%
             hierarchy_len = len(subject.location.hierarchy())
          %>
          <span class="green">
          %for index, tag in enumerate(subject.location.hierarchy(True)):
            <a class="green" href="${tag.url()}">${tag.title_short}</a>
            %if index != hierarchy_len - 1:
              |
            %endif
          %endfor
          </span>
        </p>
        %if subject.teachers:
          <p> <span class="verysmall grey bold">
            ${_("Lecturer:") if len(subject.teachers) == 1 else _("Lecturers:")}
          </span> </p>
          <ul class="teacher-list verysmall">
          %for teacher in subject.teachers:
            <li>${h.link_to(teacher.fullname, teacher.url())}</li>
          %endfor
          </ul>
        %elif subject.lecturer:
          <p> <span class="verysmall grey bold">${_('Lecturer:')}</span> </p>
          <ul class="teacher-list verysmall">
            <li>${subject.lecturer}</li>
          </ul>
        %endif
    </div>
    <div class="dalyko-info">
      <p>
        <span class="verysmall grey bold">${_('Subject rating:')} </span>
        <span>${h.image('/images/details/stars%d.png' % subject.rating(), alt='', class_='subject_rating')|n}</span>
      </p>
      <p><span class="verysmall grey bold">${_('The subject is watched by:')}</span>
          <span class="verysmall">
            ${ungettext("<span class='orange'>%(count)s</span> user", "<span class='orange'>%(count)s</span> users", subject.user_count()) % dict(count = subject.user_count())|n},
            ${ungettext("<span class='orange'>%(count)s</span> group", "<span class='orange'>%(count)s</span> groups", subject.group_count()) % dict(count = subject.group_count())|n}
          </span>
        </p>
    </div>
    <div class="dalyko-info">
        <div class="item-tags">
        % if subject.tags:
          %for tag in subject.tags:
            <a class="grey" href="${tag.url()}">${tag.title}</a>
          %endfor
        % else:
          ${_('There are no subject tags.')}
        % endif
        </div>
    </div>
    %if c.user is not None:
    %if h.check_crowds(['moderator']) and not c.subject.deleted:
      ${h.button_to(_('Delete subject'), c.subject.url(action='delete'), class_='btn btnNegative')}
    %endif
    <div style="padding-top: 5px; padding-bottom: 5px">
      %if c.user.is_teacher:
        %if c.user.teaches(subject):
          ${h.button_to(_("Remove from my taught courses"), subject.url(action='unteach'), class_='btn btnNegative', method='GET')}
        %elif c.user.teacher_verified:
          ${h.button_to(_("I teach this course"), subject.url(action='teach'), class_='btnMedium btnTeacher', method='GET')}
        %endif
      %else:
        %if c.user.watches(subject):
          ${h.button_to(_("Remove from my subjects"), subject.url(action='watch'), class_='btn btnNegative', method='GET')}
        %else:
          ${h.button_to(_("Add to my subjects"), subject.url(action='watch'), class_='btn', method='GET')}
        %endif
      %endif
    </div>
    <div class="right_arrow"><a href="${url(controller='subject', action='edit', id=subject.subject_id, tags=c.subject.location_path)}">${_('edit subject information')}</a></div>
    %endif
  </%self:uportlet>

%if c.user is None:
<script type="text/javascript"><!--
google_ad_client = "pub-1809251984220343";
/* Šoninis blokelis (300x250) */
google_ad_slot = "6884411140";
google_ad_width = 300;
google_ad_height = 250;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
%endif

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
