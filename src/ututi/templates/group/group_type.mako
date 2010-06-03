<%inherit file="/ubase.mako" />

<%def name="flash_messages()"></%def>

<%def name="title()">
${_('Choose group type')}
</%def>

<h1>${_('What kind of a group do you want to create?')}</h1>

<table class="group-type-choice">
  <tr class="group-type">
    <th>
      ${h.image('/img/icons/icon_academic.png', alt='Academic group')}
      <h2>${_('Academic group')}</h2>
    </th>
    <th>
      ${h.image('/img/icons/icon_public.png', alt='Public group')}
      <h2>${_('Public group')}</h2>
    </th>
    <th>
      ${h.image('/img/icons/icon_custom.png', alt='Custom group')}
      <h2>${_('Custom group')}</h2>
    </th>
  </tr>
  <tr class="features">
    <td>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('Mailing list')}</p>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('Private file area')}</p>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('Registration with university subjects')}</p>
    </td>
    <td>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('Web-based forum')}</p>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('Public group page')}</p>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('News publishing')}</p>
      <p class="point">${h.image('/img/icons/tick_10.png', alt='Tick')}
        ${_('No confirmation needed for membership')}</p>
    </td>
    <td>
      <p>${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Pick the functionality you need yourself')}</p>
    </td>
  </tr>
  <tr class="buttons">
    <td class="button">
      ${h.button_to(_('Create group'), url(controller='group', action='create_academic'), class_='btnPlus btnLarge', name='create-academic-group', method='GET')}
    </td>
    <td class="button">
      ${h.button_to(_('Create group'), url(controller='group', action='create_public'), class_='btnPlus btnLarge', name='create-public-group', method='GET')}
    </td>
    <td class="button">
      ${h.button_to(_('Create group'), url(controller='group', action='create_custom'), class_='btnPlus btnLarge', name='create-custom-group', method='GET')}
    </td>
  </tr>
</table>
