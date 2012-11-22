<%inherit file="/location/base.mako" />

<%def name="css()">
  ${parent.css()}

  #search-panel .search-text-submit input {
    width: 230px;
  }

  #search-panel #search_form {
    margin-bottom: 20px;
  }

  .search-results-header form.button-to,
  .search-results-header form.button-to fieldset {
    display: inline;
  }

  .search-results-header .result-count {
    float: left;
    margin: 4px 0 -2px 0;
    max-width: 400px;
  }
  .search-results-header .action-button {
    float: right;
  }
  .search-results-header .action-button .notice {
    margin-right: 10px;
  }

  .sub-department-list {
    display: inline-block;
    position: relative;
  }

  .sub-department-list > .show {
    position: absolute;
  }
</%def>

<%def name="breadcrumbs()">
<% sub_departments = getattr(c, 'sub_departments', []) %>
%if c.location.parent or sub_departments:
<ul id="breadcrumbs">
  %for n, crumb in enumerate(c.breadcrumbs, 1):
    <li class="${'first' if n == 1 else ''}">
      <a href="${crumb['link']}">${crumb['full_title']}</a>
    </li>
  %endfor
  %if sub_departments:
  <li class="sub-department-list click2show">
    <span class="click">All sub-departments</span>
    <div class="show">
      <ul>
        %for sub_department in sub_departments:
        <li class="sub-department-item"><a href="${sub_department.catalog_url(obj_type=c.current_menu_item)}">${sub_department.title}</a></li>
        %endfor
      </ul>
    </div>
  </li>
  %endif
</ul>
%endif
</%def>

<%def name="search_results(results, search_query=None)">
</%def>

<%def name="search_form()">
</%def>

<%def name="empty_box()">
</%def>

%if c.text == '' and c.results.item_count == 0:
  ${self.empty_box()}
%else:
  <div id="search-panel">
    ${self.search_form()}
    ${self.search_results(c.results, c.text)}
  </div>
%endif
