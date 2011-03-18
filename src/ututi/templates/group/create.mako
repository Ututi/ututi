<%inherit file="/group/create_base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>

<h1 class="page-title with-bottom-line">${_('Create a group')}</h1>

${self.path_steps(1)}

<form method="post" action="${url(controller='group', action='create_academic')}" enctype="multipart/form-data">

  <fieldset>
    ${self.location_field()}
    ${self.year_field()}
    ${self.forum_type_and_id()}
    <div style="height: 5px"></div>
    ${self.group_title_field()}
    ${self.logo_field()}
    ${self.description_field()}
    ${self.coupon_field()}
    ${h.input_submit(_('Continue'), class_='btnMedium', id="continue-button")}
  </fieldset>
</form>

${self.group_live_search_js()}

<%self:right_pane title="${_('Recommended groups')}">
  <ul>
    <li>${_('Enter your university and department')}</li>
    <li>${_('Find existing groups')}</li>
    <li>${_('Join one')}</li>
  </ul>
</%self:right_pane>
