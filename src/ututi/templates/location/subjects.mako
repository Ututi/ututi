<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>

<%def name="css()">
  #subject-search-panel .search-text-submit input {
    width: 230px;
  }
</%def>

<%def name="search_content()">
<div id="subject-search-panel">
${search_form(c.text, 'subject', c.location.hierarchy,
    parts=['text'], target=c.location.url(action="subjects"), js=True,
    js_target=c.location.url(action='search_js'))}

  ${search_results(c.results, controller='structureview', action='search_js')}

  %if c.user:
    <div class="create_item">
      <span class="notice">${_('Did not find what you were looking for?')}</span>
      ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'))}
    </div>
  %endif
</div>
</%def>
