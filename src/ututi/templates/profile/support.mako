<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

${h.support_button('5lt', 500, type='image', src=url('/images/5ltl.png'), alt=_('5 litas'))}
${h.support_button('10lt', 1000, type='image', src=url('/images/10ltl.png'), alt=_('10 litas'))}
${h.support_button('50lt', 5000, type='image', src=url('/images/50ltl.png'), alt=_('50 litas'))}
