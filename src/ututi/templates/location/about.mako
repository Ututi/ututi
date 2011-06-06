<%inherit file="/location/base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
</%def>

<%def name="css()">
  ${parent.css()}

  .university-box {
    margin: 25px 0;
    padding: 10px 0;
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

  h1.page-title {
    font-size: 22px;
    margin-bottom: 0px;
  }

  .sub-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 20px;
  }

  #social-network {
    float: left;
    margin-left: 20px;
  }

  .about-box {
    border: solid 1px #ccc;
    margin: 5px 0;
    padding-left: 20px;
    padding-bottom: 10px;
    width:250px;
    float: right;
  }

  .about-box .feature {
    width: 215px;
    margin-top: 10px;
  }

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
    <h2 class="single-title">${title}</h2>
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

<%def name="pageheader()">
  <h1 class="page-title">
    ${self.pagetitle()}
  </h1>
  <div class="sub-title">${_('Private social network')}</div>
</%def>

<div class="clearfix">
  <img id="social-network" src="${url('/img/social_network.png')}" alt="Social network" />
  <ul class="about-box feature-box">
    <li class="feature icon-subjects-file"><strong>${_('Academic resources')}</strong> &ndash;
    ${_('Add your study material (notes and files).')}</li>
    <li class="feature icon-group"><strong>${_('Student groups')}</strong> &ndash;
      ${_('Create and join private or public groups to communicate and collaborate.')}</li>
    <li class="feature icon-discussions"><strong>${_('Discussions')}</strong> &ndash;
      ${_('Share knowledge and discuss academic subjects with students and teachers.')}</li>
  </ul>
</div>

%if c.departments:
${university_box(c.departments, _("Departments:"))}
%endif
