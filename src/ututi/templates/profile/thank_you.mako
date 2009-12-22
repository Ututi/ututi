<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<h1>${_('Thank you for supporting Ututi!')}</h1>

<div style="background-position: 160px 50px;background-image: url(${url('/images/happy_cat.png')}); background-repeat:no-repeat; height: 400px">
<p>
${_('You have just contributed to the development of Ututi!'
    ' A medal, signifying your Ututi supporter status, should'
    ' soon appear in your profile. Good luck continuing to use Ututi!')}
</p>

<p>
${h.link_to(_('back to the profile'), url(controller='profile', action='home'), class_="forward-link")}
</p>
</div>
