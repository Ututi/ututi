<%inherit file="/registration/base.mako" />
<%namespace file="/widgets/facebook.mako" name="facebook" />

<%def name="pagetitle()">${_("Registration to VUtuti")}</%def>

${facebook.login_js(url(controller='registration', action='land_fb'), bind_account=False)}
