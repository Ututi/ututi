<%inherit file="/location/catalog.mako" />
<%namespace file="/search/index.mako" name="search" import="search_form, search_results"/>

<%def name="pagetitle()">${_('Groups')}</%def>

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
      <div class="feature icon-discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("a place to discuss study matters and your student life.")}
      </div>
      <div class="feature icon-email">
        <strong>${_("E-mail")}</strong>
        - ${_("each group has an email address. If someone writes to this address, all groupmates will receive the email.")}
      </div>
    </div>
    <div class="clearfix">
      <div class="feature icon-file">
        <strong>${_("Private group files")}</strong>
        - ${_("private file storage area for files that you don't want to share with outsiders. ")}
      </div>
      <div class="feature icon-notifications">
        <strong>${_("Subject notifications")}</strong>
        - ${_("receive notifications from subjects that your group is following.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Create a new group'), url(controller='group', action='create'), class_='add', method='GET')}
    </div>
  </div>
</%def>
