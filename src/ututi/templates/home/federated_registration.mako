<%inherit file="/ubase-nomenu.mako" />

<div id="homeRegisterBlock">
  <div>
    ${_('Please confirm that the following information about you is correct and check the box to accept the terms of use.')}
  </div>
  <div id="registrationForm" class="shown">
    <form id="registration_form" method="post"
          action="${url(controller='home', action='federated_registration')}">
      <fieldset>
        %if c.hash:
          <input type="hidden" name="hash" value="${c.hash}"/>
        %endif
        <form:error name="came_from"/>
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
        <form:error name="email"/>
        <label>
          <span class="labelText">${_('Email')}</span>
          <span class="textField">
            <input type="text" name="email" value="${c.email}"/>
            <span class="edge"></span>
          </span>
        </label>
        %if c.gg_enabled:
        <form:error name="gadugadu"/>
        <label>
          <span class="labelText">${_('Gadu gadu')}</span>
          <span class="textField">
            <input type="text" name="gadugadu" value=""/>
            <span class="edge"></span>
          </span>
        </label>
        %else:
        <input type="hidden" id="gadugadu" name="gadugadu"/>
        %endif

        <form:error name="agree"/>
        <label id="agreeWithTOC"><input type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="" onclick="return false;">${_('terms of use')}</a></label>
        <div style="text-align: center;">
          <button class="btnMedium" type="submit" value="${_('Register')}"><span>${_('Register')}</span></button>
        </div>
      </fieldset>
    </form>
  </div>
</div>
