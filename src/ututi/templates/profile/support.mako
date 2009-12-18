<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
  ${parent.head_tags()}
</%def>

${h.support_button(_('5 litas'), 500)}
${h.support_button(_('10 litas'), 1000)}
${h.support_button(_('50 litas'), 5000)}
