<%inherit file="/location/edit_base.mako" />
<%namespace file="/location/edit_theme_enabled.mako" import="theme_preview" />

<%def name="css()">
  ${parent.css()}
  .explanation-post-header .tip {
    width: 50%;
  }
</%def>

<div class="explanation-post-header" style="margin-top:0">
  <h2>${_('Custom theme')}</h2>
  <p class="tip">
    ${_("VUtuti let's you theme your network, "
        "including custom colors, header logo and text.")}
  </p>
</div>

${theme_preview(c.theme)}

${h.button_to(_("Enable custom theming"),
              c.location.url(action='enable_theme'),
              name='enable_theme')}
