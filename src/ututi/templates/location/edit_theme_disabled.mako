<%inherit file="/location/edit_base.mako" />

<%def name="css()">
  ${parent.css()}
  .explanation-post-header .tip {
    width: 50%;
  }
</%def>

<div class="explanation-post-header" style="margin-top:0">
  <h2>${_('Custom theme')}</h2>
  <p class="tip">
    ${_("Ututi let's you theme your network, "
        "including custom colors, header logo and text.")}
  </p>
</div>

${h.button_to(_("Enable custom theming"),
              c.location.url(action='enable_theme'),
              name='enable_theme')}
