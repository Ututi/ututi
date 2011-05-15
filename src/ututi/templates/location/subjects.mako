<%inherit file="/location/catalog.mako" />
<%namespace file="/search/index.mako" name="search" import="search_form"/>

<%def name="title()">
  ${c.location.title} &ndash; ${_('Subjects')}
</%def>

<%def name="pageheader()">
    ${_('Subjects')}
</%def>

<%def name="breadcrumbs()">
<ul id="breadcrumbs">
  <li>
    <a href="${c.breadcrumbs[0]['link']}">
      ${c.breadcrumbs[0]['full_title']}
    </a> |
    <a href="${c.breadcrumbs[1]['link']}">
      ${c.breadcrumbs[1]['full_title']}
    </a>
  </li>
</ul>
</%def>


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
          <span class="notice">${_("Can't find your subject?")}</span>
          ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'), class_='add inline')}
        </span>
        %endif
      </div>
    </%def>
  </%search:search_results>
</%def>

<%def name="search_form()">
  ${search.search_form(c.text, 'subject', c.location.hierarchy,
      parts=['text'], target=c.location.url(action='catalog', obj_type='subject'), js=True,
      js_target=c.location.url(action='catalog_js'))}
</%def>

<%def name="empty_box()">
  <div class="feature-box icon-subject">
    <div class="title">
      ${_("About subjects:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-file">
        <strong>${_("A place for course material sharing")}</strong>
        - ${_("upload and share course material with students of your class, university or the entire world.")}
      </div>
      <div class="feature icon-chat">
        <strong>${_("Subject forum")}</strong>
        - ${_("a place to discuss the learning matters. Subject forums bring you to your students closer than ever before!")}
      </div>
    </div>
    <div class="clearfix">
      <div class="feature icon-note">
        <strong>${_("Monitoring wiki notes")}</strong>
        - ${_("create notes for your courses collaboratively with your students.")}
      </div>
      <div class="feature icon-talk">
        <strong>${_("Easy way to reach your students")}</strong>
        - ${_("send messages to all of your students at once.")}
        ${_("When you update subject information or upload a new file, your students will be notified automatically.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Create a new subject'), url(controller='subject', action='add'), class_='add')}
    </div>
  </div>
</%def>
