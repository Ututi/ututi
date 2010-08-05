<%inherit file="/group/create_base.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/group/add.mako" import="path_steps"/>

<%def name="title()">
  ${_('New academic group')}
</%def>


  <div id="CreatePublicGroupLeft">
    <h1 class="pageTitle">${_('Create an academic group')}</h1>

    ${path_steps(0)}

    <form method="post" action="${url(controller='group', action='create_academic')}"
          id="group_settings_form" enctype="multipart/form-data">

      <fieldset>
        ${self.location_field()}
        ${self.year_field()}
        ${self.group_email_field()}
        <div style="height: 5px"></div>
        ${self.group_title_field()}
        ${self.logo_field()}
        ${self.description_field()}
        ${self.coupon_field()}
        ${h.input_submit(_('Continue'), class_='btnMedium', id="continue-button")}
      </fieldset>
    </form>

  </div>

  ${self.group_live_search_js()}

  <%self:right_pane title="${_('Recommended groups')}">
    <ul>
      <li>${_('Enter your university and department')}</li>
      <li>${_('Find existing groups')}</li>
      <li>${_('Join one')}</li>
    </ul>
  </%self:right_pane>
