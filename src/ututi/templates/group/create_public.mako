<%inherit file="/group/create_base.mako" />
<%namespace name="newlocationtag" file="/widgets/newlocationtag.mako" import="*"/>
<%namespace file="/group/add.mako" import="path_steps"/>

<%def name="title()">
${_('New public group')}
</%def>


  <div id="CreatePublicGroupLeft">
    <h1 class="pageTitle">${_('Create a public group')}</h1>

    ${path_steps(0)}

    <form method="post" action="${url(controller='group', action='create_public')}"
          id="group_settings_form" enctype="multipart/form-data">

      <fieldset>
        ${self.group_title_field()}
        ${self.web_address_field()}
        ${self.location_field()}

        ${self.logo_field()}
        ${self.description_field()}

        ${h.input_submit(_('Continue'), class_='btnMedium')}
      </fieldset>
    </form>

  </div>

  ## Can't use live search because we do not have the year.
  ## ${self.group_live_search_js()}

  <%self:right_pane title="${_('What can you do with public groups?')}" sidebar="">
      <ul>
        <li>${_('Web-based forum')}</li>
        <li>${_('Public group page')}</li>
        <li>${_('News publishing')}</li>
        <li>${_('No confirmation needed for membership')}</li>
      </ul>
  </%self:right_pane>
