<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<h2>${_('Thanks for supporting us... NOT!')}</h2>

${h.link_to(_('Back to profile'), url(controller='profile', action='home'), class_="back-link")}
