<%namespace file="/search/index.mako" name="search" import="search_form, search_results"/>

<%def name="css()">
  #subject-search-panel .search-text-submit input {
    width: 230px;
  }

  #subject-search-panel #search_form {
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
  .search-results-header .create-new-subject {
    float: right;
  }
  .search-results-header .create-new-subject .notice {
    margin-right: 10px;
  }
</%def>

<%def name="subject_search_results(results, search_query=None)">
  <%search:search_results results="${results}" controller='structureview' action='search_js'>
    <%def name="header()">
      <div class="clearfix">
        <span class="result-count">
          %if search_query:
            ${h.literal(ungettext("%(result_count)s result for <strong>%(search_query)s</strong>",
                                  "%(result_count)s results for <strong>%(search_query)s</strong>",
                                  result_count) % dict(result_count=results.item_count, search_query=search_query))}
          %else:
            ${h.literal(ungettext("%(result_count)s result <strong>total</strong>",
                                  "%(result_count)s results <strong>total</strong>",
                                  result_count) % dict(result_count=results.item_count))}
          %endif
        </span>
        %if c.user:
        <span class="create-new-subject">
          <span class="notice">${_("Can't find your subject?")}</span>
          ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'), class_='add')}
        </span>
        %endif
      </div>
    </%def>
  </%search:search_results>
</%def>

<%def name="search_content()">
<div id="subject-search-panel">
${search.search_form(c.text, 'subject', c.location.hierarchy,
    parts=['text'], target=c.location.url(action="subjects"), js=True,
    js_target=c.location.url(action='search_js'))}

${subject_search_results(c.results)}
</div>
</%def>
