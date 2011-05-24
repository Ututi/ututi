<%inherit file="/profile/home_base.mako" />
<%namespace file="/search/index.mako" name="search" import="search_results"/>

<%def name="pagetitle()">
${_('Similar subjects found')}
</%def>

<p class="warning">
  ${_("Please check that your subject is not in the list below.")}
</p>

<%search:search_results results="${c.similar_subjects}">
  <%def name="header()">
    <strong>${_("Did you mean:")}</strong>
  </%def>
</%search:search_results>

<p class="light">
  ${_("No, I want to create a new subject that is not in this list.")}
</p>

${h.button_to(_("Next"), url(controller='subject', action='add_description'), method='GET')}
