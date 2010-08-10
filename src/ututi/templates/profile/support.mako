<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

<%def name="pagetitle()">
${_('Why we need support?')}
</%def>

<p style="padding-top: 7px">${_('Ututi is just like wikipedia: every user can change, create, see and download the content for free.'
       '  But maintainance of servers, development and supervision requires recources.'
       '  So if Ututi has helped you pass an exam, write your thesis or you just like Ututi,'
       ' we are asking you to contribute by making a small donation :)')}
</p>
<p>${h.literal(_('If you donate at least 50 Lt, you will receive a gift &mdash; an Ututi T-shirt. You can donate this amount in parts.'))}</p>

<br />

<h3>${_('I want to donate:')}</h3>

<div style="padding: 2px;">
  ${h.support_button('5lt', 500, type='image', src=url('/images/5ltl.png'), alt=_('5 litas'))}
  ${h.support_button('10lt', 1000, type='image', src=url('/images/10ltl.png'), alt=_('10 litas'))}
  ${h.support_button('50lt', 5000, type='image', src=url('/images/50ltl.png'), alt=_('50 litas'))}
</div>

<br class="clear-left" />

<div style="text-align: right;">
  ${h.link_to(_('back to the profile'), url(controller='profile', action='home'), class_="forward-link")}
</div>
