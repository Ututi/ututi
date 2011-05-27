<%inherit file="/base.mako" />
<%namespace file="/profile/base.mako" name="profile"/>
<%namespace file="/portlets/user.mako" import="user_statistics_portlet,
        related_users_portlet, teacher_related_links_portlet"/>
<%namespace file="/portlets/structure.mako" import="location_teacher_list_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet"/>
<%namespace file="/elements.mako" import="tabs, location_links" />
<%namespace name="index" file="/user/index.mako" import="css" />

<%def name="teacher_page_portlets()">
  ${teacher_related_links_portlet(c.user_info)}
  ${share_portlet(c.user_info)}
  ${user_statistics_portlet(c.user_info)}
  ${location_teacher_list_portlet(c.user_info.location)}
</%def>

<%def name="portlets()">
  %if c.user is not None:
    ${profile.portlets()}
  %else:
    ${teacher_page_portlets()}
  %endif
</%def>

<%def name="portlets_secondary()">
  %if c.user is not None:
    ${teacher_page_portlets()}
  %endif
</%def>

<%def name="branded_header()">
  %for index, loc in enumerate(c.user_info.location.hierarchy(True), 1):
    <img class="university-logo logo-${index}" src="${url(controller='structure', action='logo', id=loc.id, width=140)}" alt="${loc.title}" />
    <div class="university-title title-${index}">${loc.title}</div>
  %endfor
</%def>

<%def name="header()">
  %if c.user is None and c.user_info.location.title_path == ['vu', 'mif']:
    ${branded_header()}
  %else:
    ${parent.header()}
  %endif
</%def>

<%def name="head_tags()">
  ${parent.head_tags()}
  %if c.user is None and c.user_info.location.title_path == ['vu', 'mif']:
    ${h.stylesheet_link(h.path_with_hash('/css/branded/vu-mif.css'))}
  %endif
</%def>

<%def name="title()">
  ${c.user_info.fullname}
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
  #user-information .teacher-name {
    display: none;
  }
  #user-information #user-logo {
    width: 130px;
    height: 130px;
  }
</%def>

%if c.user is not None:
<div id="public-profile-actions" class="clearfix">
  <ul class="icon-list">
    %if h.check_crowds(['root']):
      <li class="icon-admin">
        <a href="${c.user_info.url(action='login_as')}">
          ${_('Log in as %(user)s') % dict(user=c.user_info.fullname)}
        </a>
      <li>
      <li class="icon-admin">
        <a href="${c.user_info.url(action='medals')}">
          ${_('Award medals')}
        </a>
      </li>
    %endif
    <li class="icon-message">
      <a href="${url(controller='messages', action='new_message', user_id=c.user_info.id)}">
        ${_("Send private message")}
      </a>
    </li>
  </ul>
</div>
%endif

<h1 class="page-title underline">
  ${c.user_info.fullname}
</h1>

<%def name="teacher_info_block()">
<div id="user-information" class="clearfix">
  <div class="user-logo-container">
    <img id="user-logo" src="${c.user_info.url(action='logo', width=200)}" alt="logo" />
  </div>

  <div class="user-info">

    <div class="teacher-name">
      ${c.user_info.fullname}
    </div>

    %if c.user_info.teacher_position:
      <div class="teacher-position">
        ${c.user_info.teacher_position}
      </div>
    %endif

    <div class="teacher-location">
      ${location_links(c.user_info.location, full_title=True, external=True)}
    </div>

    <ul class="icon-list" id="teacher-contact-information">

      %if c.user_info.work_address:
      <li class="address icon-university">
        <span class="label">${_('Address')}:</span> ${c.user_info.work_address}
      </li>
      %endif

      %if c.user_info.phone_number and c.user_info.phone_confirmed:
      <li class="phone icon-mobile">
        <span class="label">${_('Phone')}:</span> ${c.user_info.phone_number}
      </li>
      %endif

      %if c.user_info.emails:
      <li class="email icon-contact">
        <span class="label">${_('E-mail')}:</span> ${h.literal(', '.join([h.mail_to(email.email) for email in c.user_info.emails if email.confirmed]))}
      </li>
      %endif

      %if c.user_info.site_url:
      <li class="webpage icon-network">
        <span class="label">${_('Personal webpage')}:</span> <a href="${c.user_info.site_url}">${c.user_info.site_url}</a>
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
