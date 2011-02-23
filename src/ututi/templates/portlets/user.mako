<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip, item_location" />

<%def name="user_menu_portlet()">
  <%self:portlet id="user-menu-portlet">
  <ul id="user-sidebar-menu" class="icon-list">
    <li class="icon-feed"> <a href="${url(controller='profile', action='feed')}">${_("My feed")}</a> </li>
    <li class="icon-university"> <a href="${c.user.location.url()}">${_("My university feed")}</a> </li>
    <% unread_messages = c.user.unread_messages() %>
    <li class="icon-message ${'active' if unread_messages else ''}">
      <a id="inbox-link" href="${url(controller='messages', action='index')}">
        %if unread_messages:
         <strong>${ungettext("Messages (%(count)s new)", "Messages (%(count)s new)",
                             unread_messages) % dict(count=unread_messages)}</strong>
        %else:
           ${_("Messages")}
        %endif
      </a>
    </li>
    %if c.user.memberships:
    <li class="icon-group">
      ${_("My groups:")}
      <ul>
        %for group in c.user.groups:
        <li> ${h.object_link(group)} </li>
        %endfor
      </ul>
    </li>
    %endif
  </ul>
  </%self:portlet>
</%def>

<%def name="user_subjects_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:portlet id="subject_portlet" portlet_class="inactive">
    <%def name="header()">
      ${_('Watched subjects')}
    </%def>
    %if not user.watched_subjects:
      ${_('You are not watching any subjects.')}
    %else:
    <ul id="user-subjects" class="subjects-list">
      % for subject in user.watched_subjects[:5]:
      <li>
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      % endfor
    </ul>
    %endif

    ${h.link_to(_('More subjects'), url(controller='profile', action='search', obj_type='subject'), class_="more")}
    <span>
      ${h.button_to(_('Watch subjects'), url(controller='profile', action='watch_subjects', id=user.id))}
      ${tooltip(_("Add watched subjects to your watched subjects' list and receive notifications "
                  "about changes in these subjects"))}
    </span>

  </%self:portlet>
</%def>

<%def name="user_groups_portlet(user=None, title=None, full=True)">
  <%
     if user is None:
         user = c.user
     if title is None:
       title = _('My groups:')
  %>
  <%self:portlet id="user-groups-portlet">
    <%def name="header()">
      ${title}
    </%def>
    %if not user.memberships:
      <p>${_('You are not a member of any group.')}</p>
    %endif
    <ul class="icon-list">
      %for group in user.groups:
      <li class="icon-group">
        <a href="${group.url()}" ${h.trackEvent(Null, 'groups', 'title', 'profile')}>
          ${group.title}
        </a>
      </li>
      %endfor
      <li class="icon-group">
        ${h.link_to(_('Find groups'), url(controller='profile', action='search', obj_type='group'))}
      </li>
      <li class="icon-add">
        ${h.link_to(_('Create new group'), url(controller='group', action='create_academic'))}
      </li>
    </ul>
  </%self:portlet>
</%def>

<%def name="user_information_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="user-information-portlet">
      <div class="user-logo">
        <img src="${url(controller='user', action='logo', id=user.id, width=60)}" alt="logo" />
      </div>
      <div class="user-fullname break-word">
        %if h.check_crowds(['root']):
        <a href="mailto:${user.emails[0].email}">${user.fullname}</a>
        %else:
        ${user.fullname}
        %endif
      </div>
      %if user is c.user:
      <div class="edit-profile-link break-word">
        <a href="${url(controller='profile', action='edit')}">${_("(edit profile)")}</a>
      </div>
      %endif
  </%self:portlet>
</%def>

<%def name="teacher_information_portlet(user=None, full=True, title=None)">
  <%
     if user is None:
         user = c.user

     if title is None:
         title = _("Teacher's information")
  %>
  <%self:uportlet id="user_information_portlet" portlet_class="MyProfile">
    <%def name="header()">
      ${title}
    </%def>
    <div class="profile ${'bottomLine' if user.description or user.site_url else ''}">
        <div class="floatleft avatar">
            %if user.logo is not None:
              <img src="${url(controller='user', action='logo', id=user.id, width=70, height=70)}" alt="logo" />
            %else:
              ${h.image('/img/teacher_70x70.png', alt='logo')}
            %endif
        </div>
        <div class="floatleft personal-data">
            <div><h2>${user.fullname}</h2></div>
            ${item_location(user)} | ${_("teacher")}
            %if user.emails:
              <div><a href="mailto:${user.emails[0].email}">${user.emails[0].email}</a></div>
            %endif
            %if user.phone_number and user.phone_confirmed:
              <div class="user-phone orange">${_("Phone:")} ${user.phone_number}</div>
            %endif
            %if user.site_url:
            <p class="user-link">
              <a href="${user.site_url}">${user.site_url}</a>
            </p>
            %endif
        </div>
        <div class="clear"></div>
    </div>
    %if user.description:
    <div class="about-self">${h.html_cleanup(user.description)}</div>
    %endif

  </%self:uportlet>
</%def>

<%def name="teacher_list_portlet(title, teachers)">
  %if teachers:
  <%self:uportlet id="teacher_list_portlet" portlet_class="MyProfile">
    <%def name="header()">
      ${title}
    </%def>

    <ul class="teacher-list">
    %for teacher in teachers:
      <li>${h.link_to(teacher.fullname, teacher.url())}</li>
    %endfor
    </ul>

  </%self:uportlet>
  %endif
</%def>
