<%inherit file="/group/create_base.mako" />
<%namespace name="newlocationtag" file="/widgets/newlocationtag.mako" import="*"/>
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
        ${self.group_title_field()}
        ${self.logo_field()}
        ${self.description_field()}

        ${h.input_submit(_('Continue'), class_='btnLarge')}
      </fieldset>
    </form>

  </div>

  ${self.group_live_search_js()}

  <%self:right_pane title="${_('What can you do with academic groups?')}">
      <ul>
        <li>Lorem ipsum dolor sit amet</li>
        <li>Lorem ipsum dolor sit amet dolor sit amet</li>
        <li>Lorem ipsum dolor sit amet</li>
        <li>Lorem ipsum dolor sit amet dolor sit amet</li>
      </ul>
  </%self:right_pane>
