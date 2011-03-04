<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("Registration to Ututi")}</%def>

<script type="text/javascript">
  $(document).ready(function() {
      // attempt to login FB
      FB.login(function(response) {
          if (response.session && response.perms) {
              // user is logged in and granted some permissions.
              // perms is a comma separated list of granted permissions
              window.location = '${url(controller='registration', action='confirm_fb', path='/'.join(c.location.path))}';
          }
      }, {perms:'email'});
  });
</script>
<noscript>
  <form id="registration_form" method="POST" action="${url('start_registration_with_location', path='/'.join(c.location.path))}">
    ${h.input_line('email', _("Enter your email here:"))}
    ${h.input_submit(_('Register'))}
  </form>
</noscript>
