<%inherit file="/registration/base.mako" />

<%def name="css()">
  ${parent.css()}
  #invitation-choice {
    margin-top: 10px;
  }
  #invitation-choice h2 {
    font-weight: bold;
    margin-bottom: 10px;
  }
  #email-invitation-form {
    width: 450px;
  }
  #email-invitation-form textarea#emails {
    width: 350px;
    height: 100px;
  }
  #email-invitation-form span.helpText {
    width: 350px;
  }
  #email-invitation-form div.error-container {
    width: 350px;
    display: block;
    margin: 0;
  }
</%def>

<%def name="pagetitle()">${_("Invite friends")}</%def>

<p>${_("VUtuti is most valuable when used together with your classmates and friends. Take a minute to invite them now.")}</p>

<div class="left-right" id="invitation-choice">

  <form class="left"
        id="email-invitation-form"
        action="${c.registration.url(action='invite_friends')}"
        method="POST">

    <h2>${_('Invite friends via email')}</h2>
    ${h.input_area('emails', '', help_text=_('Enter emails of your classmates, separated with commas and/or whitespace.'), cols=30)}
    ## generate error fields for variable_decode
    %for i in range(100):
    <form:error name="emails-${i}" />
    %endfor

    ${h.input_submit(_("Finish"))}
  </form>

</div>
