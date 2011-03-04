<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">
  %if hasattr(c, 'location'):
    ${_("Registration to %(university_title)s") % dict(university_title=c.location.title)}
  %else:
    ${_("Registration to Ututi")}
  %endif
</%def>

<form id="registration_form" method="POST" action="${url('start_registration_with_location', path='/'.join(c.location.path))}">
  ${h.input_line('email', _("Enter your email here:"))}
  ${h.input_submit(_('Register'))}
</form>
