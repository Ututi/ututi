<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>
<%namespace file="/portlets/universal.mako" import="item_box" />

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

<%def name="subject_followers_portlet(subject=None, count=6)">
  <%
  if subject is None: subject = c.subject
  if count is None: count = 6
  followers = h.subject_followers(subject.id, count)
  %>
  %if followers:
  <%self:portlet id='subject-followers-portlet'>
    <%def name="header()">
      ${_("Followers:")}
    </%def>
    ${item_box(followers, with_titles=True)}
  </%self:portlet>
  %endif
</%def>

<%def name="subject_related_subjects_portlet()">
  %if c.similar_subjects:
  <%self:portlet id="subject-related-subjects-portlet">
    <%def name="header()">
      ${_('Related subjects:')}
    </%def>
    %for item in c.similar_subjects:
      <div class="snippet-subject">
        <div class="heading">
          <div class="item-title">
            <a href="${item['url']}" title="${item['title']}">${item['title']}</a>
          </div>
        </div>
        <div class="description">
          <div class="location-tags">
          %for tag in item['hierarchy']:
            <a href="${tag['url']}" title="${tag['title']}">${tag['title_short']}</a> |
          %endfor
          </div>
          <div class="teachers">
          %if item['teachers']:
            ${_("Lect.")} ${item['teachers']}
          %endif
          </div>
        </div>
        <ul class="statistics icon-list">
            <li class="icon-file">${item['file_cnt']}</li>
            <li class="icon-note">${item['page_cnt']}</li>
            <li class="icon-group">${item['group_cnt']}</li>
            <li class="icon-user">${item['user_cnt']}</li>
        </ul>
      </div>
    %endfor
  </%self:portlet>
  %endif
</%def>
