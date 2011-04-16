<%inherit file="/profile/home_base.mako" />

<%def name="pagetitle()">
  ${_("Welcome to Ututi")}
</%def>

<%def name="welcome()">
<div id="welcome-message" class="flash-message">
  ${h.literal(_('Welcome to <strong>%(university)s</strong> private social network'
  'created on <a href="%(url)s">Ututi platform</a>. '
  'Here students and teachers can create groups online, use the mailinglist for '
  'communication and the file storage for sharing information.' % dict(university=c.user.location.title, url=url('/features'))))}
</div>
</%def>

%if not c.user.is_teacher:
  ${self.homepage_nags_and_stuff()}
%endif

${welcome()}
${self.group_feature_box()}
${self.subject_feature_box()}
