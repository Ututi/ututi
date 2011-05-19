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
