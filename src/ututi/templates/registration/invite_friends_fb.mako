<%inherit file="/registration/base.mako" />
<%namespace name="fb" file="/widgets/facebook.mako" />

<%def name="pagetitle()">${_("Invite friends")}</%def>

<%def name="css()">
  ${parent.css()}
  #skip-link {
    float: right;
  }
</%def>

%if c.has_facebook:
  <%
  location = c.registration.location
  invitation_message = _('Join %(university_link)s social network in Ututi, '
                         'a system for exchanging study material and information.') % \
                       dict(university_link=h.link_to(location.title, location.url()))
  %>
  ${fb.invitation_box(_('Invite your classmates to Ututi!'),
                      c.registration.url(action='invite_friends_fb'),
                      invitation_message,
                      'Join Ututi',
                      url(controller='registration', action='start_fb'),
                      c.exclude_ids)}
%else:
  <p>${_("You have to log in to Facebook in order to use this invitation form.")}</p>
  ${fb.login_button()}
  <a id="skip-link" href="${c.registration.url(action='invite_friends')}">
    ${_("Skip")}
  </a>
%endif
