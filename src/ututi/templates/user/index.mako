<%inherit file="/base.mako" />
<%namespace file="/profile/base.mako" name="profile"/>
<%namespace file="/portlets/user.mako" import="user_statistics_portlet,
        related_users_portlet, user_medals"/>
<%namespace name="snippets" file="/sections/content_snippets.mako" />
<%namespace name="wall" file="/sections/wall_entries.mako" />

<%def name="portlets()">
  ${profile.portlets()}
</%def>

<%def name="portlets_secondary()">
  ${user_statistics_portlet(c.user_info)}
  ${related_users_portlet(c.user_info)}
  ${user_medals(c.user_info)}
</%def>

<%def name="title()">
  ${c.user_info.fullname}
</%def>

<%def name="head_tags()">
  ${wall.head_tags()}
</%def>

<%def name="css()">
  #public-profile-actions {
    margin-bottom: -25px; /* adjusted to h1 height */
  }
  #public-profile-actions ul {
    float: right;
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

<div id="user-information" class="clearfix">
  <div class="user-logo-container">
    <img id="user-logo" src="${c.user_info.url(action='logo', width=120)}" alt="logo" />
  </div>

  <div class="user-info">
    <ul class="icon-list">

      <li class="icon-network">
        ${snippets.item_location_full(c.user_info)}
      </li>

      %if c.user is not None:
        ## don't show private details to anonymous
        %if c.user_info.phone_number and c.user_info.phone_confirmed:
        <li class="icon-mobile link-color">
          ${c.user_info.phone_number}
        </li>
        %endif

        %if c.user_info.emails:
        <li class="icon-contact link-color">
          ${h.literal(', '.join([h.mail_to(email.email) for email in c.user_info.emails if email.confirmed]))}
        </li>
        %endif
      %endif

      %if c.user_info.site_url:
      <li class="icon-internet">
        <a href="${c.user_info.site_url}">${c.user_info.site_url}</a>
      </li>
      %endif

    </ul>

    <div class="about-self">
      %if c.user_info.description:
        ${h.html_cleanup(c.user_info.description)}
      %endif
      %if c.user and c.user.id == c.user_info.id:
        <a href="${url(controller='profile', action='edit')}" title="${_('Edit profile')}">
          <img src="/img/icons.com/edit.png" alt="${_('Edit')}" />
        </a>
      %endif
    </div>
  </div>

</div>

<div class="page-section subjects">
  <div class="title">${_("Subjects:")}</div>
  %if c.user_info.watched_subjects:
  <div class="search-results-container">
    %for subject in c.user_info.watched_subjects:
      ${snippets.subject(subject)}
    %endfor
  </div>
  %else:
    ${_("%(user_name)s does not follow any subject.") % dict(user_name=c.user_info.fullname)}
  %endif
</div>

<div class="page-section groups">
  <div class="title">${_("Groups:")}</div>
  %if c.user_info.groups:
  <div class="search-results-container">
    %for group in c.user_info.groups:
      ${snippets.group(group)}
    %endfor
  </div>
  %else:
    ${_("%(user_name)s is not a member of any group.") % dict(user_name=c.user_info.fullname)}
  %endif
</div>

<div class="page-section events">
  <div class="title">${_("Activity:")}</div>
  %if c.events:
    <div class="wall">
      ${wall.wall_entries(c.events)}
    </div>
  %else:
    ${_("No activity yet.")}
  %endif
</div>
