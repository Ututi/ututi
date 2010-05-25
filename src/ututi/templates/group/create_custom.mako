<%inherit file="/group/create_base.mako" />

<%def name="title()">
${_('New public group')}
</%def>


  <div id="CreatePubliCGroupLeft">
    <h1 class="pageTitle">${_('Create a public group')}</h1>

    <form method="post" action="${url(controller='group', action='create_custom')}"
         id="group_add_form" enctype="multipart/form-data">

      <fieldset>
        ${self.group_title_field()}
        ${self.logo_field()}
        ${self.description_field()}
        ${self.forum_type()}
        ${self.group_email_field()}

        ${self.location_field()}

        ${self.can_add_subjects()}
        ${self.has_file_storage()}

        ${self.access_settings()}

        <br />

        ${h.input_submit(_('Continue'), class_='button buttonHuge')}
      </fieldset>
    </form>

  </div>

  ${self.group_live_search_js()}

  <%self:right_pane title="${_('What can you do with public groups?')}">
      <ul>
        <li>Lorem ipsum dolor sit amet</li>
        <li>Lorem ipsum dolor sit amet dolor sit amet</li>
        <li>Lorem ipsum dolor sit amet</li>
        <li>Lorem ipsum dolor sit amet dolor sit amet</li>
      </ul>
  </%self:right_pane>
