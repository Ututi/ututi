<%inherit file="/ubase.mako" />

<%def name="flash_messages()"></%def>

<%def name="title()">
${_('Choose group type')}
</%def>

<h1>${_('What kind of a group do you want to create?')}</h1>

<table class="group-type-choice">
  <tr>
    <th>
      <h2>${h.image('/img/icons/icon_academic.png', alt='Academic group')}
        ${_('Academic group')}</h2>
    </th>
    <th>
      <h2>${h.image('/img/icons/icon_public.png', alt='Public group')}
        ${_('Public group')}</h2>
    </th>
    <th>
      <h2>${h.image('/img/icons/icon_custom.png', alt='Custom group')}
        ${_('Custom group')}</h2>
    </th>
  </tr>
  <tr>
    <td>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Mailing list')}</p>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Private file area')}</p>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Registration with university subjects')}</p>
    </td>
    <td>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Web-based forum')}</p>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Public group page')}</p>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('News publishing')}</p>
      <p class="point">${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('No confirmation needed for membership')}</p>
    </td>
    <td>
      <p>${h.image('/img/icons/tick_big.png', alt='Tick')}
        ${_('Pick the functionality you need yourself')}</p>
    </td>
  </tr>
  <tr>
    <td class="button">
      ${h.button_to(_('Create group'), url(controller='group', action='create_academic'), class_='btnPlus btnLarge')}
    </td>
    <td class="button">
      ${h.button_to(_('Create group'), url(controller='group', action='create_public'), class_='btnPlus btnLarge')}
    </td>
    <td class="button">
      ${h.button_to(_('Create group'), url(controller='group', action='create_custom'), class_='btnPlus btnLarge')}
    </td>
  </tr>
</table>
