<%inherit file="/location/catalog.mako" />
<%namespace file="/search/index.mako" name="search" import="search_form, search_results"/>

<%def name="teacher_snippet(teacher)">
  ${teacher.snippet()}
</%def>

<%def name="title()">
  ${c.location.title} &ndash; ${_('Teachers')}
</%def>

<%def name="pagetitle()">${_('Teachers')}</%def>

<%def name="search_results(results, search_query=None)">
  <%search:search_results results="${results}" controller='structureview' action='catalog_js' display="${self.teacher_snippet}">
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
        %if c.user and not c.user.is_teacher:
        <span class="action-button">
          <span class="notice">${_("Are you also a teacher in this University?")}</span>
          ${h.button_to(_('I am a teacher'), c.location.url(action='register_teacher'), class_='inline', method='GET')}
        </span>
        %endif
      </div>
    </%def>
  </%search:search_results>
</%def>

<%def name="search_form()">
  ${search.search_form(c.text, 'teacher', c.location.hierarchy,
      parts=['text'], target=c.location.url(action='catalog', obj_type='teacher'), js=True,
      js_target=c.location.url(action='catalog_js'))}
</%def>

<%def name="empty_box()">
  <div class="feature-box icon-group">
    <div class="title">
      ${_("About teachers:")}
    </div>
    <div class="clearfix">
      <div class="feature icon-file">
        <strong>${_("Teacher profile")}</strong>
        - ${_("submit your CV, thoughts, biography and academic papers.")}
      </div>
      <div class="feature icon-subjects-file">
        <strong>${_("Course material sharing")}</strong>
        - ${_("upload and share course material with students of your class, university or the entire world.")}
      </div>
      <div class="feature icon-email">
        <strong>${_("Direct messaging")}</strong>
        - ${_("create a private dialog with one or multiple students or groups.")}
      </div>
      <div class="feature icon-discussions">
        <strong>${_("Discussions")}</strong>
        - ${_("discuss tought courses with your students.")}
      </div>
    </div>
    <div class="action-button">
      ${h.button_to(_('Become a teacher'), c.location.url(action='register_teacher'), method='GET')}
    </div>
  </div>
</%def>
