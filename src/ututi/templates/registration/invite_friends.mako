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
  #invite-friends-form div.error-container {
    width: 350px;
    display: block;
    margin: 0;
  }
</%def>

<%def name="pagetitle()">${_("Invite friends")}</%def>

<p>${_("Ututi is most valuable when used together with your classmates and friends. Take a minute to invite them now.")}</p>

<div class="clearfix" id="invitation-choice">

  <form id="invite-friends-form"
        action="${c.registration.url(action='invite_friends')}"
        method="POST">

    <p class="invite-choice">${_('Invite friends via email')}</p>
    ${h.input_area('emails', '', help_text=_('Enter emails of your classmates, separated with commas and/or whitespace.'), cols=30)}
    ## generate error fields for variable_decode
    %for i in range(100):
    <form:error name="emails-${i}" />
    %endfor

    ${h.input_submit(_("Finish"))}
  </form>

  <div id="facebook-invite-box">
    <p class="invite-choice">${_('Invite friends via facebook')}</p>
    <a id="facebook-button" href="${c.registration.url(action='invite_friends_fb', qualified=True)}">
      ${h.image('/img/facebook-button.png', alt=_('Facebook'))}
    </a>
  </div>

</div>
