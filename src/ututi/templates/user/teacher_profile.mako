<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/user.mako" import="*"/>
<%namespace file="/sections/content_snippets.mako" import="item_location" />
<%namespace file="/sections/standard_objects.mako" import="subject_listitem" />

<%def name="portlets()">
</%def>

<%def name="title()">
  ${c.user_info.fullname}
</%def>

<%def name="css()">
#teacher-public-profile {
  margin-top: 20px;
}

#teacher-public-profile #avatar {
  float: left;
}

#teacher-public-profile #personal-data {
  margin-left: 150px;
  font-size: 11px;
}

#teacher-public-profile #personal-data #contacts {
  margin: 5px 0;
}

#teacher-public-profile #personal-data #social-buttons {
  float: right;
  text-align: right;
}

#teacher-public-profile #personal-data #about-self {
  clear: right;
}

#teacher-public-profile #actions {
  clear: both;
  background: #f8f8f8;
  margin-top: 5px 0;
  padding: 5px;
}

#teacher-public-profile #actions form {
  display: inline-block;
}
</%def>

<div id="teacher-public-profile">
  <div id="avatar" style="float:left">
      %if c.user_info.logo is not None:
        <img src="${url(controller='user', action='logo', id=c.user_info.id, width=130, height=130)}" alt="logo" />
      %else:
        ${h.image('/img/teacher_130x130.png', alt='logo')}
      %endif
  </div>

  <div id="personal-data">
    <h1>${_('Teacher')} ${c.user_info.fullname}</h1>

    <div id="contacts">
      ${item_location(c.user_info)} | ${_("teacher")}
      %if c.user_info.phone_number and c.user_info.phone_confirmed:
        <div class="user-phone orange">${_("Phone:")} ${c.user_info.phone_number}</div>
      %endif

      <div id="social-buttons">
        ${_("Teacher online:")}
        <br />
        <a href="#"><img src="${url('/img/social/facebook_16.png')}" /></a>
        <a href="#"><img src="${url('/img/social/twitter_16.png')}" /></a>
      </div>

      %if c.user_info.site_url:
      <p class="user-link">
        <a href="${c.user_info.site_url}">${c.user_info.site_url}</a>
      </p>
      %endif
    </div>

    %if c.user_info.description:
    <div id="about-self">${c.user_info.description}</div>
    %endif
  </div>

  <div id="actions">
    %if c.user is not None:
      ${h.button_to(_('Watch teacher'), url('#'))}
      <div style="float:right">
      ${h.button_to(_('Send message'), url(controller='messages', action='new_message', user_id=c.user_info.id))}
      </div>
    %endif

    %if h.check_crowds(['root']):
      ${h.button_to(_('Log in as %(user)s') % dict(user=c.user_info.fullname), url=c.user_info.url(action='login_as'))}
      ${h.button_to(_('Award medals'), url=c.user_info.url(action='medals'))}
    %endif
  </div>

  %if c.user_info.taught_subjects:
  <div id="taught-courses">
    <h2>${_("Taught courses")}</h2>
    %for n, subject in enumerate(c.user_info.taught_subjects):
      ${subject_listitem(subject, n)}
    %endfor
  </div>
  %endif

</div>
