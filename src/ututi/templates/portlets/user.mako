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
  <% if user is None: user = c.user %>
  <%self:portlet id="user-subjects-portlet">
    <%def name="header()">
      ${_('My subjects:')}
    </%def>
    %if not user.watched_subjects:
      <p>${_('You are not watching any subjects.')}</p>
    %endif
    <ul class="icon-list">
      %for subject in user.watched_subjects:
      <li class="icon-subject">
        <a href="${subject.url()}" title="${subject.title}">${h.ellipsis(subject.title, 35)}</a>
      </li>
      %endfor
      <li class="icon-find">
        ${h.link_to(_('Find subjects'), url(controller='profile', action='search', obj_type='subject'))}
      </li>
      <li class="icon-add">
        ${h.link_to(_('Create new subject'), url(controller='subject', action='add'))}
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
      <li class="icon-find">
        ${h.link_to(_('Find groups'), url(controller='profile', action='search', obj_type='group'))}
      </li>
      <li class="icon-add">
        ${h.link_to(_('Create new group'), url(controller='group', action='create_academic'))}
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

<%def name="invite_friends_portlet(user=None)">
  <% if user is None: user = c.user %>
  <%self:portlet id="invite-friends-portlet">
    <%def name="header()">
      ${_("Invite friends:")}
    </%def>
    <ul class="icon-list">
      <li class="icon-facebook">
        <a href="#invite-facebook" id="invite-facebook-link">${"Via facebook"}</a>
      </li>
      <li class="icon-email">
        <a href="#invite-email" id="invite-email-link">${"Via e-mail"}</a>
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

        $("#invite-facebook-link").click(function() {
          FB.ui(
            {
              method: 'feed',
              name: 'TODO title',
              link: 'TODO link',
              caption: 'TODO caption',
              message: "${_("Here's what I've found in Ututi")}" + '!',
              description: 'TODO description',
              picture: '${url("/img/site_logo_collapsed.gif", qualified=True)}'
            }
          );
          return false;
        });


      });
      //]]>
    </script>
  </%self:portlet>
</%def>

<%def name="user_information_portlet(user=None, full=True, title=None)">
  <%
     if user is None:
         user = c.user

     if title is None:
         title = _('My profile')
  %>
  <%self:uportlet id="user_information_portlet" portlet_class="MyProfile">
    <%def name="header()">
      ${title}
    </%def>
    <div class="profile ${'bottomLine' if user.description or user.site_url else ''}">
        <div class="floatleft avatar">
            %if user.logo is not None:
              <img src="${url(controller='user', action='logo', id=user.id, width=70, height=70)}" alt="logo" />
              <img src="${url(controller='user', action='logo', id=user.id, width=70, height=70)}" alt="logo" />
            %else:
              ${h.image('/img/profile-avatar.png', alt='logo')|n}\
            %endif
        </div>
        <div class="floatleft personal-data">
        <div class="floatleft personal-data">
            <div><h2>${user.fullname}</h2></div>
            % if h.check_crowds(['root']):
              <div><a href="mailto:${user.emails[0].email}">${user.emails[0].email}</a></div>
            % endif
            <div class="medals" id="user-medals">
              %for medal in user.all_medals():
                ${medal.img_tag()}
              %endfor
            </div>
            <div class="file_stats">
              ${_('Files uploaded:')}<span class="user_file_count"> ${user.files_count()}</span>
              <br/>
              <br/>
              ${_('Files downloaded:')}<span class="user_file_count"> ${user.download_count()} (${h.file_size(user.download_size())})</span>
            </div>
        </div>
        <div class="clear"></div>
    </div>
##    <div class="profile">Šią savaitę dar gali atsisiųsti:<img src="img/icons/indicator.png" alt="" class="indicator"><span class="verysmall">75Mb</span>
##      <p class="img-button">
##        <form action="">
##          <fieldset>
##          <legend class="a11y">pridėti</legend>
##          <label><span><button value="submit" class="btn"><span>padidinti atsiuntimų kiekį</span></button></span></label>
##          </fieldset>
##        </form>
##      </p>
##    </div>
##    <div class="profile"><p>Nori daugiau?</p>
##      <div class="isplesk-button floatleft"><a href="">išplėsk profilį</a></div>
##      <p class="qu"><a href=""><img src="img/icons/question_sign.png" alt="" class="img-question-button"></a></p>
##  </div>
    <div class="about-self">${user.description}</div>
    %if user.site_url:
    <p class="user-link">
      <a href="${user.site_url}">${user.site_url}</a>
    </p>
    %endif

  </%self:uportlet>
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
