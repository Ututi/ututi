<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="*"/>
<%namespace file="/elements.mako" import="item_box" />

<%def name="subject_info_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  %if subject.description:
  <%self:portlet id="subject-information-portlet">
    <%def name="header()">
      ${_('Info')}
    </%def>
    <div class="description">
      ${h.ellipsis(h.html_strip(subject.description), 300)}
    </div>
    %if c.user:
      <a href="${subject.url(action='info')}" id="more-link">${_('more')}</a>
    %endif
  </%self:portlet>
  %endif
</%def>

<%def name="subject_follow_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  %if c.user is not None:
    <%self:portlet id="subject-follow-portlet">
      %if c.user.is_teacher:
        %if c.user.teaches(subject):
          ${h.button_to(_("Remove from my taught courses"), subject.url(action='unteach'), class_='dark', method='GET')}
        %else:
          ${h.button_to(_("I teach this course"), subject.url(action='teach'), class_='dark add', method='GET')}
        %endif
      %else:
        %if c.user.watches(subject):
          ${h.button_to(_("Unfollow"), subject.url(action='watch'), class_='dark', method='GET')}
        %else:
          ${h.button_to(_("Follow"), subject.url(action='watch'), class_='dark add', method='GET')}
        %endif
      %endif
    </%self:portlet>
  %endif
</%def>

<%def name="subject_teachers_portlet(subject=None)">
  <% if subject is None: subject = c.subject %>
  <%self:portlet id="subject-teachers-portlet">
    <ul class="icon-list">
      <li class="icon-university align-top subject-location">
        %if subject.location.parent is None:
          ${_("University:")}
        %else:
          ${_("Faculty / department:")}
        %endif
        <br />
        ${h.link_to(subject.location.title, subject.location.url())}
      </li>
      %if subject.teacher_repr:
      <li class="icon-teacher align-top subject-teacher">
        %if subject.teachers:
          ${ungettext('Lecturer:', 'Lecturers:', len(subject.teachers))}
          <br />
          ${subject.teacher_repr}
        %elif subject.lecturer:
          ${_('Lecturer:')}
          <br />
          ${subject.lecturer}
        %endif
        %if h.check_crowds(["moderator"], c.user, subject.location):
            <div style="margin-top: 8px;">
            ${h.button_to(_("Manage lecturers"), subject.url(action='teacher_assignment'), class_='dark', method='GET')}
            </div>
        %endif
      </li>
      %endif
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

<%def name="subject_permission_link_portlet()">
  %if h.check_crowds(['teacher', 'moderator']):
    <%self:portlet id="subject-permission-link-portlet">
      <%def name="header()"></%def>
      <a class="settings-link" href="${c.subject.url(action='permissions')}">${_("Edit permissions")}</a>
    </%self:portlet>
  %endif
</%def>
