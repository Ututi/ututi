<%inherit file="/base.mako" />

<%def name="title()">
${_('Terms of use')}
</%def>

<div id="terms-of-use-text">
  ${h.get_i18n_text('terms')}
</div>
