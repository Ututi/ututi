<%inherit file="/location/base.mako" />

<%def name="head_tags()">
  ${parent.head_tags()}
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
    <h2 class="single-title underline">${title}</h2>
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

%if hasattr(c, 'departments'):
${university_box(c.departments, _("Departments:"))}
%endif

