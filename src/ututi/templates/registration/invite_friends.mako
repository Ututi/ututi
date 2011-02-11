<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("Invite friends")}</%def>

<form id="invite-friends-form"
      action="${url(controller='registration', action='invite_friends', hash=c.registration.hash)}"
      method="POST">

  <p>${_("Lorem ipsum dolor sit amet, consectetur adipisicing...")}</p>

  ${h.input_line('email1', _('Invite friends via email'), right_next=c.email_suffix)}
  ${h.input_line('email2', None, right_next=c.email_suffix)}
  ${h.input_line('email3', None, right_next=c.email_suffix)}
  ${h.input_line('email4', None, right_next=c.email_suffix)}
  ${h.input_line('email5', None, right_next=c.email_suffix)}

  ${h.input_submit(_("Finish"))}
</form>

## TODO: FACEBOOK INVITE
