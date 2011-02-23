<%inherit file="/portlets/base.mako"/>
<%namespace file="/sections/content_snippets.mako" import="tooltip, item_location" />

<%def name="user_menu_portlet()">
  <%self:portlet id="user-menu-portlet">
  <ul id="user-sidebar-menu">
    <li> <a href="${url(controller='profile', action='feed')}">${_("My feed")}</a> </li>
    <li> <a href="${c.user.location.url()}">${_("My university feed")}</a> </li>
    <li>
      <% unread_messages = c.user.unread_messages() %>
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
    <li>
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
       title = _('My groups')
  %>
  <%self:uportlet id="user-groups-portlet" portlet_class="inactive">
    <%def name="header()">
      ${title}
    </%def>
    % if not user.memberships:
      ${_('You are not a member of any.')}
    %else:
    <ul>
      % for group in user.groups:
      <li>
        <dl class="group-listing-item">
          %if group.logo is not None:
            <img class="group-logo" src="${url(controller='group', action='logo', id=group.group_id, width=25, height=25)}" alt="logo" />
          %else:
            ${h.image('/images/details/icon_group_25x25.png', alt='logo', class_='group-logo')|n}
          %endif
            <dt class="group-title"><a href="${group.url()}" ${h.trackEvent(Null, 'groups', 'title', 'profile')}>${group.title}</a></dt>
            <dd class="member-count">(${ungettext("%(count)s member", "%(count)s members", len(group.members)) % dict(count = len(group.members))})</dd>
            <div class="group-location">
              <dd>
                <a href="${group.location.url()}">${' | '.join(group.location.title_path)}</a>
              </dd>
            </div>
        </dl>
      </li>
      % endfor
    </ul>
    %endif
    %if full:
    <div class="footer">
      <div class="new-group">
        ${h.link_to(_('Create group'), url(controller='group', action='create_academic'), method='GET')}
      </div>
      ${tooltip(_('Create your group, invite your classmates and use the mailing list, upload private group files'))}

      <span class="more-link">
        ${h.link_to(_('More groups'), url(controller='profile', action='search', obj_type='group'), class_="right_arrow")}
      </span>
      <br style="clear-both"/>
    </div>

    %endif
  </%self:uportlet>
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

<%def name="user_create_subject_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:action_portlet id="subject_create_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'user_new_subject', 'action_portlets')} href="${url(controller='subject', action='add')}">${_('create new subject')}</a>
    ${tooltip(_("Store all the subject's files and notes in one place."),
              style='margin-top: 4px;')}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="user_create_group_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:action_portlet id="group_create_portlet">
    <%def name="header()">
    <a class="blark" ${h.trackEvent(None, 'click', 'user_new_group', 'action_portlets')} href="${url(controller='group', action='create_academic')}">${_('create new group')}</a>
    ${tooltip(_("Communicate with your classmates, colleagues and friends, share files and news together!"),
              style='margin-top: 4px;')}

    </%def>
  </%self:action_portlet>
</%def>

<%def name="user_recommend_portlet(user=None)">
  <%
     if user is None:
         user = c.user
  %>
  <%self:action_portlet id="user_recommend_portlet" expanding="True" label="ututi_recommend">
    <%def name="header()" >
    ${_('recommend Ututi to your friends')}
    </%def>

    <div id="recommendation_status">
    </div>
    <form method="post"
          action="${url(controller='home', action='send_recommendations')}" id="ututi_recommendation_form">
      <div class="form-field">
        <input type="hidden" name="came_from" value="${request.url}" />
        <label class="textField" for="recommend_emails">${_('Enter the emails of your classmates, separated by commas or new lines.')}
          <textarea name="recommend_emails" id="recommend_emails" rows="4"></textarea>
        </label>
      </div>

      <div class="form-field">
        <br />
        <button class="btn" id="recommendation_submit" type="submit" value="${_('Send invitation')}" ${h.trackEvent(None, 'action_portlets', 'send', 'ututi_recommend')}>
          <span>${_('Send invitation')}</span>
        </button>
      </div>
    </form>
    <br />
  <script type="text/javascript">
  //<![CDATA[
    $(document).ready(function() {
      $('#recommendation_submit').click(function() {
        $(this).parents('.form-field').addClass('loading');
        _gaq.push(['_trackEvent', 'action_portlets', 'send', 'ututi_recommend']);
        $.post("${url(controller='home', action='send_recommendations', js=1)}",
            $(this).parents('form').serialize(),
            function(data) {
              status = $('#recommendation_status').text('').append(data);
              $('#recommendation_submit').parents('.form-field').removeClass('loading');
              $('#recommend_emails').val('');
            });
        return false;
      });
    });
  //]]>
  </script>


  </%self:action_portlet>
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
