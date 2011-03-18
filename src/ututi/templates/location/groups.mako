<%inherit file="/location/catalog.mako" />
<%namespace file="/search/index.mako" name="search" import="search_form, search_results"/>

<%def name="search_results(results, search_query=None)">
  <%search:search_results results="${results}" controller='structureview' action='catalog_js'>
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
        <span class="action-button">
          <span class="notice">${_("Can't find your group?")}</span>
          ${h.button_to(_('Create a new group'), url(controller='group', action='create'), class_='add inline', method='GET')}
        </span>
        %endif
      </div>
    </%def>
  </%search:search_results>
</%def>

<%def name="search_form()">
  ${search.search_form(c.text, 'group', c.location.hierarchy,
      parts=['text'], target=c.location.url(action='catalog', obj_type='group'), js=True,
      js_target=c.location.url(action='catalog_js'))}
</%def>

<%def name="empty_box()">
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
      ${h.button_to(_('Create a new group'), url(controller='group', action='create'), class_='add', method='GET')}
    </div>
  </div>
</%def>
