%if c.location.parent is None:
<%inherit file="/location/university.mako" />
%else:
<%inherit file="/location/department.mako" />
%endif
<%namespace file="/location/university.mako" import="*"/>
<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/search/index.mako" import="search_results"/>

<%def name="search_content()">
${search_form(c.text, 'subjects', c.location.hierarchy,
    parts=['text'], target=c.location.url(action="subjects"), js=True,
    js_target=c.location.url(action='subjects_search_js'))}
 
  ${search_results(c.results, controller='structureview', action='search_js')}
 
  %if c.user:
    <div class="create_item">
      <span class="notice">${_('Did not find what you were looking for?')}</span>
      ${h.button_to(_('Create a new group'), url(controller='group', action='add'))}
      ${h.image('/images/details/icon_question.png', alt=_('Create your group, invite your classmates and use the mailing list, upload private group files'), class_='tooltip')|n}
    </div>
  %endif
</%def> 
