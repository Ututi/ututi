<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/sections.mako" import="user_sidebar"/>
<%namespace file="/portlets/user.mako" import="user_statistics_portlet,
        related_users_portlet, teacher_list_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet"/>
<%namespace file="/elements.mako" import="tabs" />
<%namespace name="index" file="/user/index.mako" import="css" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />


<%def name="portlets()">
  ${share_portlet(c.user_info)}
  ${user_statistics_portlet(c.user_info)}
  %if c.user_info.location:
  <% title =  _("Other %(university)s teachers") % dict(university=' '.join(c.user_info.location.title_path)) %>
  ${teacher_list_portlet(title, c.all_teachers)}
  %endif
</%def>

<%def name="title()">
  ${_("Teacher's %(user)s public profile") % dict(user=c.user_info.fullname)}
</%def>

<%def name="css()">
   ${parent.css()}
   ${index.css()}
</%def>

<h1 class="page-title with-bottom-line">
  ${_('Teacher')} ${c.user_info.fullname}
</h1>

<div id="user-information" class="clearfix">
  <div class="user-logo">
    <img id="user-logo" src="${c.user_info.url(action='logo', width=130)}" alt="logo" />
  </div>

  <div class="user-info">
    <ul class="icon-list">

      <li class="icon-network">
        <strong>${_('Network')}:</strong> ${snippets.item_location_full(c.user_info)}
      </li>

      %if c.user_info.phone_number and c.user_info.phone_confirmed:
      <li class="icon-mobile">
        <strong>${_('Phone:')}:</strong> ${c.user_info.phone_number}
      </li>
      %endif

      %if c.user_info.emails:
      <li class="icon-contact">
        <strong>${_('E-mail')}:</strong> ${h.literal(', '.join([h.mail_to(email.email) for email in c.user_info.emails if email.confirmed]))}
      </li>
      %endif

      %if c.user_info.site_url:
      <li class="icon-internet">
        <strong>${_('Personal webpage')}:</strong><br /><a href="${c.user_info.site_url}">${c.user_info.site_url}</a>
      </li>
      %endif

      ## <li class="icon-social-buttons">
      ##   <a href="#"><img src="${url('/img/social/facebook_16.png')}" /></a>
      ##   <a href="#"><img src="${url('/img/social/twitter_16.png')}" /></a>
      ## </div>

    </ul>
  </div>
</div>

<div class="section subjects">
  <div class="title">${_("Taught courses")}:</div>
  %if c.user_info.taught_subjects:
  <div class="search-results-container">
    %for subject in c.user_info.taught_subjects:
      ${snippets.subject(subject)}
    %endfor
  </div>
  %else:
    ${_("%(user_name)s doesn't teach any course.") % dict(user_name=c.user_info.fullname)}
  %endif
</div>

<div class="section biography">
  <div class="title">${_("Biography")}:</div>
%if c.user_info.description:
  <div id="teacher-biography" class="wiki-page">
    ${h.html_cleanup(c.user_info.description)}
  </div>
%else:
  <div id="no-description-block">
  <h2>${_("There is no biography.")}</h2>
%endif
</div>
