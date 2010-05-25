<%inherit file="/base.mako" />

<%def name="flash_messages()"></%def>

<%def name="title()">
${_('Choose group type')}
</%def>

<h1>${_('What kind of a group do you want to create?')}</h1>

<div>
${h.link_to(_('Academic group'), url(controller='group', action='create_academic'))}
</div>

<div>
${h.link_to(_('Public group'), url(controller='group', action='create_public'))}
</div>

<div>
${h.link_to(_('Custom group'), url(controller='group', action='create_custom'))}
</div>
