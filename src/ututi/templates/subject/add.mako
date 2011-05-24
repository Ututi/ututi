<%inherit file="/profile/home_base.mako" />

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

<div class="feature-box one-column icon-subject">
  <div class="title">
    ${_("Add courses you teach")}
  </div>
  <div class="clearfix">
    <div class="feature icon-file-upload">
      <strong>${_("Files upload")}</strong> &ndash; ${_("You will be able to upload course material, that will be accessable for everyone, who is following your course.")}
    </div>
    <div class="feature icon-discussions">
      <strong>${_("Course discussions")}</strong> &ndash; ${_("Discuss course material and related subjects with your students.")}
    </div>
    <div class="feature icon-notifications">
      <strong>${_("Automatic notifications")}</strong> &ndash; ${_("Ututi will automaticaly inform students and groups about changes in course material.")}
    </div>
  </div>
</div>

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
