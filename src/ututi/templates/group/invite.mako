<%inherit file="/group/base_wide.mako" />
<%namespace name="fb" file="/widgets/facebook.mako" />

<%def name="title()">
  ${_('Invite friends to %s') % c.group.title}
</%def>

%if c.has_facebook:
  ${fb.invitation_box(_('Invite your friends to VUtuti!'),
                      c.group.url(action='invite_fb'),
                      _('Join our group <a href="%s">%s</a> in VUtuti, '
                        'a system for exchanging study materials and information.') % \
                        (c.group.url(), c.group.title),
                      _('Join group'),
                      url(controller='registration', action='confirm_fb'),
                      c.exclude_ids)}
%else:
  <p>${_("You have to log in to Facebook in order to use this invitation form.")}</p>
  ${fb.login_button()}
%endif
