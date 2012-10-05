<%inherit file="/portlets/base.mako" />
<%namespace file="/elements.mako" import="item_box" />
<%namespace file="/frontpage.mako" import="new_university_popup" />

<%def name="location_logo_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if location.has_logo():
  <%self:portlet id="location-logo-portlet">
    <div class="logo-container">
      <img src="${url(controller='structure', action='logo', id=location.id, width=140)}" alt="${location.title}" />
    </div>
  </%self:portlet>
  %endif
</%def>

<%def name="location_info_portlet(location=None)">
  <% if location is None: location = c.location %>
  <%self:portlet id="location-info-portlet">
    <%def name="header()">
      ${_("Info:")}
    </%def>
    <ul class="icon-list">
      %if location.site_url is not None:
      <li class="icon-contact">
        <a href="${location.site_url}">${location.site_url}</a>
      </li>
      %endif
      <li class="icon-subject">
        <% cnt = h.location_count(location.id, 'subject') %>
        ${ungettext("%(count)s Subject", "%(count)s Subjects", cnt) % dict(count = cnt)}
      </li>
      <li class="icon-group">
        <% cnt = h.location_count(location.id, 'group') %>
        ${ungettext("%(count)s Group", "%(count)s Groups", cnt) % dict(count = cnt)}
      </li>
      <li class="icon-user member-count">
        <% cnt = h.location_count(location.id, 'user') %>
        ${ungettext("%(count)s Member", "%(count)s Members", cnt) % dict(count = cnt)}
      </li>
      <li class="icon-file">
        <% cnt = h.location_count(location.id, 'file') %>
        ${ungettext("%(count)s File", "%(count)s Files", cnt) % dict(count = cnt)}
      </li>
    </ul>
  </%self:portlet>
</%def>

<%def name="location_admin_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if h.check_crowds(['moderator']):
    <%self:portlet id="location-admin-portlet">
      <%def name="header()">
        ${_("Administration:")}
      </%def>
      <a href="${location.url(action='edit')}">${_('Edit information')}</a>
    </%self:portlet>
  %endif
</%def>

<%def name="location_register_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if c.user is None:
  <%self:portlet id="location-register-portlet">
    ${h.button_to(_("I study here"),
                  location.url(action='register'),
                  id='i-study-here-button',
                  class_='dark',
                  method='GET')}
  </%self:portlet>
  %endif
</%def>

<%def name="location_register_teacher_portlet(location=None)">
  <% if location is None: location = c.location %>
  %if c.user is None or not c.user.is_teacher:
  <%self:portlet id="location-register-teacher-portlet">
    ${h.button_to(_("I teach here"),
                  location.url(action='register_teacher'),
                  id='i-teach-here-button',
                  class_='dark',
                  method='GET')}
  </%self:portlet>
  %endif
</%def>

<%def name="location_dont_study_here_portlet()">
 <%self:portlet id="dont-study-here-portlet">
    <p><strong>${_("Don't study here?")}</strong></p>
    <a class="add_university_button" href="#add_university">
      <button class="student" type="button">
          <img class="icon" alt="I am a student" src="${url('/img/icons/add-icon.png')}">
          ${_('Add your university')}
      </button>
    </a>

    ${new_university_popup()}
  </%self:portlet> 
</%def>

<%def name="location_groups_portlet(location=None)">
  <%
  if location is None: location = c.location
  groups = h.location_latest_groups(location.id, 6)
  %>
  %if groups:
  <%self:portlet id="location-groups-portlet">
    <%def name="header()">
      ${_('Latest groups:')}
    </%def>
    ${item_box(groups, with_titles=True)}
    <%def name="footer()">
      <span class="icon-find">
        ${h.link_to(_('All groups'), location.url(action='catalog', obj_type='group'))}
      </span>
    </%def>
  </%self:portlet>
  %endif
</%def>

<%def name="location_members_portlet(location=None, count=6)">
  <%
  if location is None: location = c.location
  members = h.location_members(location.id, count)
  %>
  %if members:
  <%self:portlet id='location-members-portlet'>
    <%def name="header()">
      ${_("Members:")}
    </%def>
    ${item_box(members, with_titles=True)}
  </%self:portlet>
  %endif
</%def>

<%def name="location_teacher_list_portlet(location=None)">
  <%
  if location is None: location = c.location
  teachers = h.location_teachers(location.id)
  %>
  %if teachers:
  <%self:portlet id="location-teacher-list-portlet">
    <%def name="header()">
      <span class="university-abbr">${' '.join(location.title_path)}</span> ${_("teachers:")}
    </%def>
    <ul class="icon-list" id="teacher-list">
    %for teacher in teachers:
      <li class="icon-teacher">
        ${h.link_to(teacher['name'], teacher['url'])}
      </li>
    %endfor
    </ul>
  </%self:portlet>
  %endif
</%def>

