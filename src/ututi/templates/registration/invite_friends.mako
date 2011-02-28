<%inherit file="/registration/base.mako" />

<%def name="css()">
  ${parent.css()}
  #facebook-invite-box {
    margin-top: 10px;
    width: 390px;
    float: right;
    text-align: center;
  }
  p.invite-choice {
    font-weight: bold;
    margin-top: 0px;
  }
  #invite-friends-form {
    margin-top: 10px;
    width: 450px;
    float: left;
    border-right: 1px solid #666666;
  }
  #invite-friends-form textarea#emails {
    width: 350px;
    height: 100px;
  }
  #invite-friends-form span.helpText {
    width: 350px;
  }
</%def>

<%def name="pagetitle()">${_("Invite friends")}</%def>

<p>${_("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et")}</p>

<div class="clearfix" id="invitation-choice">

  <form id="invite-friends-form"
        action="${c.registration.url(action='invite_friends')}"
        method="POST">

    <p class="invite-choice">${_('Invite friends via email')}</p>
    ${h.input_line('email1', None, right_next=c.email_suffix)}
    ${h.input_line('email2', None, right_next=c.email_suffix)}
    ${h.input_line('email3', None, right_next=c.email_suffix)}
    ${h.input_line('email4', None, right_next=c.email_suffix)}
    ${h.input_line('email5', None, right_next=c.email_suffix)}

    ${h.input_submit(_("Finish"))}
  </form>

  <div id="facebook-invite-box">
    <p class="invite-choice">${_('Invite friends via facebook')}</p>
    <a id="facebook-button" href="${c.registration.url(action='invite_friends_fb', qualified=True)}">
      ${h.image('/img/facebook-button.png', alt=_('Facebook'))}
    </a>
  </div>

</div>
