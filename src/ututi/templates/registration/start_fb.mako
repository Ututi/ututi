<%inherit file="/registration/base.mako" />
<%namespace file="/widgets/facebook.mako" name="init_facebook" />

<%def name="pagetitle()">${_("Registration to Ututi")}</%def>

${init_facebook()}
<script type="text/javascript">
  $(document).ready(function() {
      // attempt to login FB
      FB.login(function(response) {
          if (response.session && response.perms) {
              // user is logged in and granted some permissions.
              // perms is a comma separated list of granted permissions
              window.location = '${url(controller='registration', action='confirm_fb')}';
          }
      }, {perms:'email'});
  });
</script>
<noscript>
  <form id="registration_form" method="POST" action="${c.location.url(action='register')}">
    ${h.input_line('email', _("Enter your email here:"))}
    ${h.input_submit(_('Register'))}
  </form>
</noscript>
