<%inherit file="/base.mako" />
<%namespace file="/portlets/user.mako" import="user_statistics_portlet,
        related_users_portlet, teacher_list_portlet, teacher_related_links_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet"/>
<%namespace file="/elements.mako" import="tabs, location_links" />
<%namespace name="base" file="/user/teacher_base.mako" />
<%namespace name="index" file="/user/index.mako" import="css" />
<%namespace name="snippets" file="/sections/content_snippets.mako" />


<%def name="portlets()">
  ${teacher_related_links_portlet(c.user_info)}
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
  ${base.css()}
</%def>

<h1 class="page-title underline">
  ${c.user_info.fullname}
</h1>

${base.teacher_info_block()}

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

<div class="section information">
  <div class="title">
    ${_("General Information")}:
  </div>
%if c.user_info.description:
  <div id="teacher-information" class="wiki-page">
    ${h.html_cleanup(c.user_info.description)}
  </div>
%else:
  <div id="no-description-block">
    <h2>${_("There is no information.")}</h2>
  </div>
%endif
</div>
