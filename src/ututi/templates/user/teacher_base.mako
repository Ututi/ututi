<%inherit file="/base.mako" />
<%namespace file="/profile/base.mako" name="profile"/>
<%namespace file="/portlets/user.mako" import="user_statistics_portlet,
        related_users_portlet" />
<%namespace file="/portlets/structure.mako" import="location_teacher_list_portlet, sub_department_teacher_list_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet"/>
<%namespace file="/elements.mako" import="tabs, location_links" />
<%namespace name="index" file="/user/index.mako" import="css" />

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="portlets_secondary()">
  ${share_portlet(c.teacher)}
  ${user_statistics_portlet(c.teacher)}
  %if c.teacher.sub_department is not None:
  ${sub_department_teacher_list_portlet(c.teacher.sub_department)}
  %else:
  ${location_teacher_list_portlet(c.teacher.location)}
  %endif
</%def>

<%def name="title()">
  ${c.teacher.fullname}
</%def>

<%def name="css()">
  ${parent.css()}
  ${index.css()}
  .teacher-position {
    font-size: 14px;
  }
  #user-information .label {
    font-weight: bold;
  }
  #user-information #user-logo {
    width: 130px;
    height: 130px;
  }
</%def>

<div id="public-profile-actions" class="clearfix">
  <ul class="icon-list">
    %if h.check_crowds(['root']):
      <li class="icon-admin">
        <a href="${c.teacher.url(action='login_as')}">
          ${_('Log in as %(user)s') % dict(user=c.teacher.fullname)}
        </a>
      <li>
      <li class="icon-admin">
        <a href="${c.teacher.url(action='medals')}">
          ${_('Award medals')}
        </a>
      </li>
    %endif
    <li class="icon-message">
      <a href="${url(controller='messages', action='new_message', user_id=c.teacher.id)}">
        ${_("Send private message")}
      </a>
    </li>
  </ul>
</div>

<h1 class="page-title underline">
  ${c.teacher.fullname}
</h1>

<%def name="teacher_info_block()">
<div id="user-information" class="clearfix">
  <div class="user-logo-container">
    <img id="user-logo" src="${c.teacher.url(action='logo', width=200)}" alt="logo" />
  </div>

  <div class="user-info">

    %if c.teacher.teacher_position:
      <div class="teacher-position">
        ${c.teacher.teacher_position}
      </div>
    %endif

    <div class="teacher-location">
      ${location_links(c.teacher.location, full_title=True, external=False, sub_department=c.teacher.sub_department)}
    </div>

    <ul class="icon-list" id="teacher-contact-information">

      %if c.teacher.work_address:
      <li class="address icon-university">
        <span class="label">${_('Address')}:</span> ${c.teacher.work_address}
      </li>
      %endif

      %if c.teacher.phone_number:
      <li class="phone icon-mobile">
        <span class="label">${_('Phone')}:</span> ${c.teacher.phone_number}
      </li>
      %endif

      %if c.teacher.emails:
      <li class="email icon-contact">
        <span class="label">${_('E-mail')}:</span> ${h.literal(', '.join([h.mail_to(email.email) for email in c.teacher.emails if email.confirmed]))}
      </li>
      %endif

      %if c.teacher.site_url:
      <li class="webpage icon-network">
        <span class="label">${_('Personal webpage')}:</span> <a href="${c.teacher.site_url}">${c.teacher.site_url}</a>
      </li>
      %endif

      ## <li class="icon-social-buttons">
      ##   <a href="#"><img src="${url('/img/social/facebook_16.png')}" /></a>
      ##   <a href="#"><img src="${url('/img/social/twitter_16.png')}" /></a>
      ## </div>

    </ul>
  </div>
</div>
</%def>

${teacher_info_block()}

${tabs(c.tabs, c.current_tab)}

${next.body()}
