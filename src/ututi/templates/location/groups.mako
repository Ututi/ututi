<%namespace file="/search/index.mako" name="search" import="search_form, search_results"/>

<%def name="css()">
  #group-search-panel .search-text-submit input {
    width: 230px;
  }

  #group-search-panel #search_form {
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
  .search-results-header .create-new-group {
    float: right;
  }
  .search-results-header .create-new-group .notice {
    margin-right: 10px;
  }
</%def>

<%def name="group_search_results(results, search_query=None)">
  <%search:search_results results="${results}" controller='structureview' action='search_js'>
    <%def name="header()">
      <div class="clearfix">
        <span class="result-count">
          %if search_query:
            ${h.literal(ungettext("%(result_count)s result for <strong>%(search_query)s</strong>",
                                  "%(result_count)s results for <strong>%(search_query)s</strong>",
                                  results.item_count) % dict(result_count=results.item_count, search_query=search_query))}
          %else:
            ${h.literal(ungettext("%(result_count)s result <strong>total</strong>",
                                  "%(result_count)s results <strong>total</strong>",
                                  results.item_count) % dict(result_count=results.item_count))}
          %endif
        </span>
        %if c.user:
        <span class="create-new-group">
          <span class="notice">${_("Can't find your group?")}</span>
          ${h.button_to(_('Create a new group'), url(controller='group', action='create_academic'), class_='add inline', method='GET')}
        </span>
        %endif
      </div>
    </%def>
  </%search:search_results>
</%def>

<%def name="search_content()">
%if c.results.item_count:
  <div id="group-search-panel">
    ${search.search_form(c.text, 'group', c.location.hierarchy,
        parts=['text'], target=c.location.url(action="groups"), js=True,
        js_target=c.location.url(action='search_js'))}

    ${group_search_results(c.results)}
  </div>
%else:
  <div class="feature-box icon-group">
    <div class="title">
      ${_("About groups:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-file">
        <strong>${_("Discussions")}</strong>
        - ${_("lorem ipsum dolor sit amet...")}
      </div>
      <div class="feature icon-chat">
        <strong>${_("E-mail")}</strong>
        - ${_("lorem ipsum dolor sit amet...")}
      </div>
    </div>
    <div class="clearfix">
      <div class="feature icon-note">
        <strong>${_("Private group files")}</strong>
        - ${_("lorem ipsum dolor sit amet...")}
      </div>
      <div class="feature icon-talk">
        <strong>${_("Group watching subjects")}</strong>
        - ${_("lorem ipsum dolor sit amet...")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Create a new group'), url(controller='group', action='create_academic'), class_='add', method='GET')}
    </div>
  </div>
%endif
</%def>
