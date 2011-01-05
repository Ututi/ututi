<%inherit file="/ubase.mako" />

<div id="teacher-registration-page">
  <div class="two-panel-layout with-right-panel">
    <div class="left-panel">
      <h1 class="page-title">${_("Register as teacher:")}</h1>
      <form id="registration_form" method="post" action="${url(controller='teacher', action='federated_registration')}" class="new-style-form" style="margin-top: 50px">
        <fieldset>
          <p>${_("Please verify that the data below is correct.")}</p>
          <form:error name="invitation_hash"/>
          <input type="hidden" name="invitation_hash" value="" />
          %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
          %endif

          <form:error name="fullname"/>
          <label>
            <span class="labelText">${_('Full name')}</span>
            <span class="textField">
              <input type="text" name="fullname"/>
              <span class="edge"></span>
            </span>
          </label>
          <label>
            <span class="labelText">${_('Email address:')}</span>
            <span class="textField">
              <input type="text" id="email-field" name="email" disabled="disabled" value="${c.email}"/>
              <span class="edge"></span>
            </span>
            <script>
              $('input#email-field').val('${c.email}');
            </script>
          </label>
          <input type="hidden" name="gadugadu" value="" />
          <input type="hidden" name="phone" value="" />

          <div style="margin-top: 10px;">
          <label><input class="checkbox" checked="checked" type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}" rel="nofollow">${_('terms of use')}</a></label>
          </div>
          <form:error name="agree" />
            ${h.input_submit(_('Register'), class_='btnMedium')}
        </fieldset>
      </form>
    </div>
    <div class="right-panel">
      <h1 class="page-title">${_("Advantages of a teacher's profile:")}</h1>
      <ul class="feature-list">
        <li class="teacher-profile">
          <strong>${_("Teacher profile")}</strong>
          - ${_("submit your CV, thoughts, biography and academic papers.")}
        </li>
        <li class="file-sharing">
          <strong>${_("Course material sharing")}</strong>
          - ${_("upload and share course material with students of your class, university or the entire world.")}
        </li>
        <li class="contact-groups">
          <strong>${_("Direct messaging")}</strong>
          - ${_("create a private dialog with one or multiple students or groups.")}
        </li>
        <li class="sms">
          <strong>${_("SMS")}</strong>
          - ${_("send SMSs to your groups or friends. Get notifications and updates to your cell phone.")}
        </li>
      </ul>
    </div>
  </div>
</div>
