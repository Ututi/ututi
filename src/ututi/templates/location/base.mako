<%inherit file="/ubase-sidebar.mako" />
<%namespace file="/portlets/structure.mako" import="location_logo_portlet, location_info_portlet,
                                                    location_admin_portlet, location_register_portlet,
                                                    location_register_teacher_portlet,
                                                    location_members_portlet, location_groups_portlet"/>
<%namespace file="/portlets/universal.mako" import="share_portlet" />
<%namespace file="/elements.mako" import="tabs"/>

<%def name="css()">
  ${parent.css()}

  .university-box {
    margin: 25px 0;
    border: 1px solid #ffaf37;
    padding: 10px;
  }

  .university-box .box-title {
    font-weight: bold;
    margin-bottom: 10px;
    float: left;
  }

  .university-box .create-link {
    float: right;
  }

  .university-box .university-entry {
    color: #666666;
    width: 50%;
    float: left;
    margin-top: 5px;
  }

  .university-entry .logo {
    float: left;
    margin-right: 7px;
    margin-top: 2px;
  }

  .university-entry .logo img {
    width: 30px;
    height: 30px;
  }

  .university-entry .title {
    font-weight: bold;
    color: #333333;
  }

  .university-entry ul.statistics li {
    display: inline-block;
    margin-right: 5px;
    min-width: 20px;    /* makes icons line up nicely in list */
  }

</%def>

<%def name="portlets()">
  ${location_logo_portlet()}
  ${location_admin_portlet()}
  ${location_info_portlet()}
  ${location_register_portlet()}
  ${location_register_teacher_portlet()}
  ${share_portlet(c.location)}
  ${location_members_portlet(count=6)}
  ${location_groups_portlet()}
</%def>

<%def name="title()">
  ${c.location.title}
</%def>

<%def name="pagetitle()">
  ${c.location.title}
</%def>

<%def name="university_entry(uni)">
<div class="university-entry clearfix">
  <div class="logo">
    <img src="${url(controller='structure', action='logo', id=uni['id'], width=30, height=30)}"
         alt="logo" />
  </div>
  <div class="title">
    <a href="${uni['url']}" title="${uni['title']}">${h.ellipsis(uni['title'], 36)}</a>
  </div>
  <ul class="icon-list statistics">
    <li class="icon-subject"> ${uni['n_subjects']} </li>
    <li class="icon-group"> ${uni['n_groups']} </li>
    <li class="icon-file"> ${uni['n_files']} </li>
  </ul>
</div>
</%def>

<%def name="university_box(unis, title)">
%if unis:
<div class="university-box clearfix">
  <div class="clearfix">
    <div class="box-title">${title}</div>
    %if h.check_crowds(['moderator']):
      <a class="create-link" href="${url(controller='structure', action='index')}">
        ${_("+ Add department")}
      </a>
    %endif
  </div>
  %for uni in unis:
    ${university_entry(uni)}
  %endfor
</div>
%endif
</%def>

<h1 class="page-title">${self.pagetitle()}</h1>

%if hasattr(c, 'departments'):
${university_box(c.departments, _("Departments:"))}
%endif

${tabs()}

${next.body()}
