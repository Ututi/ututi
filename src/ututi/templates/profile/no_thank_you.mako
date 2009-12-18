<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<h2>${_('Very sad...')}</h2>

<div style="background-position: 160px 40px;background-image: url(${url('/images/sad_cat.jpg')}); background-repeat:no-repeat; height: 400px">
<p>
${_('We are very disappointed that you have decided not to support Ututi. We hope you will support us next time. Good luck!')}
</p>

<p>
${h.link_to(_('back to the profile'), url(controller='profile', action='home'), class_="forward-link")}
</p>
</div>
