<%inherit file="/location/base.mako" />

<%def name="pagetitle()">
  ${_("Teacher registration to %(university_title)s") % dict(university_title=c.location.title)}
</%def>

<form id="registration_form" method="POST" action="${c.location.url(action='register_teacher')}">
  ${h.input_line('email', _("Enter your email here:"))}
  ${h.input_submit(_('Register'))}
</form>
