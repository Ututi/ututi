<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<%def name="pagetitle()">
${_('Very sad...')}
</%def>

<div class="no_thank_you">
<p>
${_('We are very disappointed that you have decided not to support VUtuti. We hope you will support us next time. Good luck!')}
</p>

<p style="padding-top: 3px; text-align: right;">
${h.link_to(_('back to the profile'), url(controller='profile', action='home'), class_="forward-link")}
</p>
</div>
