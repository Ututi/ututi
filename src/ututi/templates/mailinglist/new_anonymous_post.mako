<%inherit file="/mailinglist/base.mako" />

<%def name="title()">
${_('Message to the group')}
</%def>

<h1>${_('Message')}</h1>

<form method="post" action="${url(controller='mailinglist', action='post_anonymous', id=c.group.group_id)}"
     id="anonymous-post-form">
  ${h.input_line('subject', _('Subject'))}
  ${h.input_area('message', _('Message'))}
  <br />
  ${h.input_submit(_('Post'))}
</form>
