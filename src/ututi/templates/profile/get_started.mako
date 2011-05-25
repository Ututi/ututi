<%inherit file="/profile/get_started_base.mako" />
<%namespace name="b" file="/sections/standard_blocks.mako" import="title_box"/>

<%def name="css()">
${parent.css()}

button#create-new-group {
  font-weight: normal;
}
#group-features {
  width: 200px;
}
#invite-friends-form {
  width: auto;
}
#subject-search-form input {
  margin-right: 5px;
}
subject-search-form input,
#invite-friends-form textarea,
#invite-friends-form .helpText {
  width: 280px;
}
#invite-friends-form .submit {
  margin-top: 10px;
}
#invite-friends-facebook {
  width: 200px;
  padding: 0 15px;
  text-align: center;
}
#invite-friends-facebook p {
  margin-top: 0px;
}
</%def>

<% done = h.user_done_items(c.user) %>

<div class="steps">
  <div class="step ${'complete' if 'invitation' in done else ''}">
    <div class="heading">
      <span class="number">1</span>
      <span class="title">${_("Invite your friends")}</span>
    </div>
    <div class="content">
      <div class="left-right">
        <form class="left" action="${url(controller='profile', action='invite_friends_email')}" method="POST" id="invite-friends-form">
          <textarea name="recipients"></textarea>
          <span class="helpText">
            ${_("Enter comma separated list of email addresses.")}
          </span>
          ${h.input_submit(_("Invite"), class_='dark add inline')}
        </form>
        <div id="invite-friends-facebook" class="right">
          <p>${_("Or use Facebook to invite your friends.")}</p>
          <a id="facebook-button" href="${url(controller='profile', action='invite_friends_fb')}">
            ${h.image('/img/facebook-button.png', alt=_('Facebook'))}
          </a>
        </div>
      </div>
    </div>
  </div>
  <div class="step clearfix ${'complete' if 'group' in done else ''}">
    <div class="heading">
      <span class="number">2</span>
      <span class="title">${_("Join the group")}</span>
    </div>
    <%b:title_box title="${_('Features:')}" id="group-features" class_="side-box">
      <ul class="feature-list small">
        <li class="email">${_("Group's email")}</li>
        <li class="files">${_("Private group files")}</li>
        <li class="notifications">${_("Subject notifications")}</li>
        <li class="discussions">${_("Private discussions")}</li>
      </ul>
    </%b:title_box>
    <div class="content">
      <p>${_("Find and join your group or create a new one.")}</p>
      ${h.button_to(_('Create a new group'), url(controller='group', action='create'),
        class_='add inline', method='GET', id='create-new-group')}
      <div class="alternative-link">
        <a href="${c.user.location.url(action='catalog', obj_type='group')}">
          ${_("Or browse group catalog")}
        </a>
      </div>
    </div>
  </div>
  <div class="step ${'complete' if 'subject' in done else ''}">
    <div class="heading">
      <span class="number">3</span>
      <span class="title">${_("Choose your subjects")}</span>
    </div>
    <div class="content">
      <p>${_("Find subjects in your university and start following them.")}</p>
      <form id="subject-search-form" action="${c.user.location.url(action='catalog', obj_type='subject')}" method="POST">
        <input type="text" name="text" />
        ${h.input_submit(_('Search'), '', class_='inline')}
      </form>
      <div class="alternative-link">
        <a href="${url(controller='subject', action='add')}">
          ${_("Or create new subject")}
        </a>
      </div>
      <p>${_("Share course material, create wiki notes and discuss with other subject followers.")}</p>
    </div>
  </div>
  <div class="step ${'complete' if 'profile' in done else ''}">
    <div class="heading">
      <span class="number">4</span>
      <span class="title">${_("Fill your profile information")}</span>
    </div>
    <div class="content">
      <p>${_("Tell some basic information about yourself by editing your profile.")}</p>
      ${h.button_to(_("Edit profile"), url(controller='profile', action='edit'),
                    method='GET', class_='dark edit')}
    </div>
  </div>
</div>
