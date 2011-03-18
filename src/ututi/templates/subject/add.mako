<%inherit file="/profile/base.mako" />

<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/widgets/tags.mako" import="*"/>

<%def name="css()">
  ${parent.css()}
  #location-edit-link {
    margin-left: 15px;
  }
</%def>

<%def name="pagetitle()">
${_('Create new subject')}
</%def>

<%def name="head_tags()">
  <%newlocationtag:head_tags />
</%def>

<%def name="form(action)">
<form method="post" action="${action}" id="subject_add_form">
  <fieldset>
  ${standard_location_widget()}
  ${h.input_line('title', _('Subject title:'))}
  ${h.input_submit(_('Next'))}
  </fieldset>
</form>
</%def>

<%self:form action="${url(controller='subject', action='lookup')}" />
