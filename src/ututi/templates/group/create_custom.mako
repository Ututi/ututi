<%inherit file="/group/create_base.mako" />

<%def name="title()">
${_('New custom group')}
</%def>


  <div id="CreatePublicGroupLeft">
    <h1 class="pageTitle">${_('Create a custom group')}</h1>

    <form method="post" action="${url(controller='group', action='create_custom')}"
          id="group_settings_form" enctype="multipart/form-data">

      <fieldset>
        ${self.group_title_field()}
        ${self.logo_field()}
        ${self.description_field()}
        ${self.forum_type_and_id()}

        ${self.location_field()}
        ${self.year_field()}

        ${self.can_add_subjects()}
        ${self.has_file_storage()}

        ${self.access_settings()}

        <br />

        ${h.input_submit(_('Continue'), class_='btnLarge')}
      </fieldset>
    </form>

  </div>

  ${self.group_live_search_js()}

  <%self:right_pane title="${_('What can you do with custom groups?')}">
      <ul>
        <li>${_('Pick the functionality you need yourself')}</li>
      </ul>
  </%self:right_pane>
