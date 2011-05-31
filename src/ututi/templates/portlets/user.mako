<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="item_location" />
<%namespace file="/elements.mako" import="tooltip, item_box" />

<%def name="user_menu_portlet()">
  <%self:portlet id="user-menu-portlet">
  <ul id="user-sidebar-menu" class="icon-list">
    %if not c.user.is_teacher and c.user.is_freshman():
    <li class="icon-ututi"> <a href="${url(controller='profile', action='get_started')}">${_("Get started")}</a> </li>
    %endif
    %if c.user.is_teacher:
    <li class="icon-teacher"> <a href="${url(controller='profile', action='dashboard')}">${_("Dashboard")}</a> </li>
    %endif
    <li class="icon-feed"> <a href="${url(controller='profile', action='feed')}">${_("News feed")}</a> </li>
    <li class="icon-university"> <a href="${c.user.location.url()}">${_("University feed")}</a> </li>
    <% unread_messages = c.user.unread_messages() %>
    <li class="icon-message ${'active' if unread_messages else ''}">
      <a id="inbox-link" href="${url(controller='messages', action='index')}">
        %if unread_messages:
         <strong>${_("Private messages (%(count)s)" % dict(count=unread_messages))}</strong>
        %else:
           ${_("Private messages")}
        %endif
      </a>
    </li>
  </ul>
  </%self:portlet>
</%def>

<%def name="user_subjects_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="user-subjects-portlet">
    <%def name="header()">
      ${_('My subjects:')}
    </%def>
    <ul class="icon-list">
      %for subject in user.watched_subjects:
      <li class="icon-subject">
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      %endfor
      <li class="icon-add">
        ${h.link_to(_('Add subject'), url(controller='subject', action='add'))}
      </li>
    </ul>
  </%self:portlet>
</%def>

<%def name="user_groups_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="user-groups-portlet">
    <%def name="header()">
      ${_('My groups:')}
    </%def>
    <ul class="icon-list">
      %for group in user.groups:
      <li class="icon-group">
        <a href="${group.url()}" ${h.trackEvent(Null, 'groups', 'title', 'profile')}>
          ${group.title}
        </a>
      </li>
      %endfor
      <li class="icon-find">
        ${h.link_to(_('Find groups'), user.location.url(action='catalog', obj_type='group'))}
      </li>
      <li class="icon-add">
        ${h.link_to(_('Create new group'), url(controller='group', action='create'))}
      </li>
    </ul>
  </%self:portlet>
</%def>

<%def name="profile_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="user-information-portlet">
      <div class="user-logo">
        <img src="${url(controller='user', action='logo', id=user.id, width=60)}" alt="logo" />
      </div>
      <div class="user-fullname break-word">
        ${user.fullname}
      </div>
      %if user is c.user:
      <div class="edit-profile-link break-word">
        <a href="${url(controller='profile', action='edit')}">${_("(edit profile)")}</a>
      </div>
      %endif
  </%self:portlet>
</%def>

<%def name="user_description_portlet(user=None)">
  <% if user is None: user = c.user %>
  %if user.description:
  <%self:portlet id="user-description-portlet">
    <p>${user.description}</p>
  </%self:portlet>
  %endif
</%def>

<%def name="user_medals(user=None)">
  <% if user is None: user = c.user %>
  %if user.all_medals():
  <%self:portlet id="user-medals-portlet">
    <%def name="header()">
      ${_("Medals")}
    </%def>
    %for medal in user.all_medals():
      ${medal.img_tag()}
    %endfor
  </%self:portlet>
  %endif
</%def>

<%def name="todo_portlet(user=None)">
  <% if user is None: user = c.user %>
  %if user is not None:
    <%
    if user.is_teacher:
      todo_items = h.teacher_todo_items(user)
    else:
      todo_items = h.user_todo_items(user)
    all_done = True
    for item in todo_items:
      all_done = all_done and item['done']
    %>
    %if not all_done:
    <%self:portlet id="todo-portlet">
      <%def name="header()">
        ${_("What to do next?")}
      </%def>
      %for n, item in enumerate(todo_items, 1):
        %if item['done']:
          <p class="done">${"%d. %s" % (n, item['title'])}</p>
        %else:
          <p><a href="${item['link']}">${"%d. %s" % (n, item['title'])}</a></p>
        %endif
      %endfor
    </%self:portlet>
    %endif
  %endif
</%def>

<%def name="invite_friends_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="invite-friends-portlet">
    <%def name="header()">
      ${_("Invite friends:")}
    </%def>
    <ul class="icon-list">
      <li class="icon-facebook">
        <a href="${url(controller='profile', action='invite_friends_fb')}" id="invite-fb-link">${"Facebook"}</a>
      </li>
      <li class="icon-email">
        <a href="#invite-email" id="invite-email-link">${"Email"}</a>
      </li>
    </ul>

    <div id="invite-email-dialog">
      <form action="${url(controller='profile', action='invite_friends_email')}" method="POST" class="new-style-form" id="invite-email-form">
        ${h.input_line('recipients', _("Recipients:"),
                       help_text=_("Enter comma separated list of email addresses"))}
        ${h.input_area('message', _("Add personal message (optional):"))}
        ${h.input_submit(_("Send invitation"), id='invite-submit-button', class_='dark')}
      </form>
      <p id="invitation-feedback-message">${_("Your invitations were successfully sent.")}</p>
    </div>

    <div id="invite-fb-dialog">
    </div>

    <script type="text/javascript">
      //<![CDATA[
      $(document).ready(function() {
        $('#invite-email-dialog').dialog({
            title: '${_("Invite friends via email")}',
            width: 330,
            autoOpen: false,
            resizable: false
        });

        $("#invite-email-link").click(function() {
          $('#invite-email-dialog').dialog('open');
          return false;
        });

        $('#invite-submit-button').click(function(){
            $.post("${url(controller='profile', action='invite_friends_email_js')}",
                   $(this).closest('form').serialize(),
                   function(data, status) {
                       if (data.success != true) {
                           // remove older error messages
                           $('.error-message').remove();
                           for (var key in data.errors) {
                               var error = data.errors[key];
                               $('#' + key).parent().after($('<div class="error-message">' + error + '</div>'));
                           }
                       }
                       else {
                           // show feedback to user
                           $('#invite-email-dialog').addClass('email-sent').delay(1000).queue(function() {
                               // close and clean up
                               $(this).dialog('close');
                               $(this).removeClass('email-sent');
                               $('.error-message').remove();
                               $(this).find('#recipients').val('');
                               $(this).dequeue();
                           });
                       }
                   },
                   "json");

            return false;
        });

      });
      //]]>
    </script>
  </%self:portlet>
</%def>

<%def name="user_statistics_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="user-statistics-portlet">
    <%def name="header()">
      ${_("Info:")}
    </%def>
    <%
    up_count = user.files_count()
    down_count = user.download_count()
    note_count = h.authorship_count('page', user.id)
    group_count = len(user.groups)
    subject_count = len(user.watched_subjects)
    %>
    <ul class="icon-list">
      <li class="icon-subject">
        ${ungettext("%(count)s subject",\
                    "%(count)s subjects",\
                    subject_count) % dict(count=subject_count)}
      </li>
      <li class="icon-group">
        ${ungettext("%(count)s group",\
                    "%(count)s groups",\
                    group_count) % dict(count=group_count)}
      </li>
      <li class="icon-note">
        ${ungettext("%(count)s wiki note",\
                    "%(count)s wiki notes",\
                    note_count) % dict(count=note_count)}
      </li>
      <li class="icon-file active">
        <span class="user-upload-count">
          ${ungettext("%(count)s file uploaded",\
                      "%(count)s files uploaded",\
                      up_count) % dict(count=up_count)}
        </span>
      </li>
      <li class="icon-file">
        <span class="user-download-count">
          ${ungettext("%(count)s file downloaded",\
                      "%(count)s files downloaded",\
                      down_count) % dict(count=down_count)}
        </span>
        (${h.file_size(user.download_size())})
      </li>
    </ul>
  </%self:portlet>
</%def>

<%def name="related_users_portlet(user=None, count=None)">
  <%
     if user is None:
         user = c.user
     if count is None: count = 6
     users = h.related_users(user.id, user.location.id, count)
  %>
  %if users:
  <%self:portlet id='related-users-portlet'>
    <%def name="header()">
      ${_("Related members:")}
    </%def>
    ${item_box(users, with_titles=True)}
  </%self:portlet>
  %endif
</%def>

<%def name="teacher_information_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="user-information-portlet">
     <div class="user-logo">
       <img src="${user.url(action='logo', width=60)}" alt="logo" />
     </div>
     <div class="user-fullname break-word">
       ${_("Teacher")} ${user.fullname}
     </div>
     %if user is c.user:
     <div class="edit-profile-link break-word">
       <a href="${url(controller='profile', action='edit')}">${_("(edit profile)")}</a>
     </div>
     %endif
  </%self:portlet>
</%def>

<%def name="teacher_related_links_portlet(teacher=None)">
  <% if teacher is None: teacher = c.user %>
  %if teacher:
  <%self:portlet id="related-links-portlet">
    <%def name="header()">
      ${_("Related links:")}
    </%def>
    <ul class="icon-list" id="related-links-list">
      %for tag in reversed(teacher.location.hierarchy(True)):
        %if tag.site_url:
          <li class="icon-university">
            <%
            if tag.parent is None:
              title = tag.title # use full title
            else:
              title = ' '.join([t.upper() for t in tag.title_path] + [_("website")])
            %>
            ${h.link_to(title, tag.site_url)}
          </li>
        %endif
      %endfor
      <li class="icon-university">
        ${h.link_to(_("%(title_abbr)s social network") % \
          dict(title_abbr=teacher.location.title_short.upper()),
          teacher.location.url())}
      </li>
    </ul>
  </%self:portlet>
  %endif
</%def>

<%def name="profile_page_portlet()">
  %if c.user is not None:
  <%self:portlet id="profile-page-portlet">
    <%def name="header()">
      ${_("My profile page")}
    </%def>
    ${h.button_to(_("Edit profile"), url(controller='profile', action='edit'),
                  method='GET', class_='dark edit')}
    <a class="forward-link" href="${c.user.url()}">
      ${_("View my profile page")}
    </a>
  </%self:portlet>
  %endif
</%def>
