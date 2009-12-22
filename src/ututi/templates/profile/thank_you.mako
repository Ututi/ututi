<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<h1>${_('Thank you for supporting Ututi!')}</h1>

<div class="thank_you">
<p>
${_('You have just contributed to the development of Ututi!'
    ' A medal, signifying your Ututi supporter status, should'
    ' soon appear in your profile. Good luck continuing to use Ututi!')}
</p>

<p style="padding-top: 3px;">
${h.link_to(_('back to the profile'), url(controller='profile', action='home'), class_="forward-link")}
</p>
</div>
