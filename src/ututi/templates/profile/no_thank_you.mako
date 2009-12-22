<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<h1>${_('Very sad...')}</h1>

<div class="no_thank_you">
<p>
${_('We are very disappointed that you have decided not to support Ututi. We hope you will support us next time. Good luck!')}
</p>

<p style="padding-top: 3px;">
${h.link_to(_('back to the profile'), url(controller='profile', action='home'), class_="forward-link")}
</p>
</div>
