<%inherit file="/portlets/base.mako"/>

<%def name="ututi_join_portlet()">
  <%self:portlet id="ututi_join_portlet">
    <%def name="header()">
      ${_('Join Ututi')}
    </%def>
      <form id="registration_form" method="post" action="${url('/register')}">
        %if c.hash:
          <input type="hidden" name="hash" value="${c.hash}"/>
        %endif

        <form:error name="fullname"/>
        <div class="form-field">
          <div class="input-line"><div>
            <input class="line" type="text" id="fullname" name="fullname" size="40"/>
          </div></div>
          <label for="fullname">${_('Fullname')}</label>
        </div>
        <form:error name="email"/>
        <div class="form-field">
          <div class="input-line"><div>
            % if c.email:
              <input  type="text" id="email" name="email" size="40" value="${c.email}" disabled="disabled" class="line"/>
              <input  type="hidden" name="email" value="${c.email}" />
            % else:
              <input  type="text" id="email" name="email" size="40" class="line"/>
            % endif
          </div></div>
          <label for="email">${_('Email')}</label>
        </div>
        <form:error name="new_password"/>
        <div class="form-field">
          <div class="input-line"><div>
            <input class="line" type="password" id="new_password" name="new_password" size="40"/>
          </div></div>
          <label for="new_password">${_('Password')}</label>
        </div>
        <form:error name="repeat_password"/>
        <div class="form-field">
          <div class="input-line"><div>
            <input class="line" type="password" id="repeat_password" name="repeat_password" size="40"/>
          </div></div>
          <label for="repeat_password">${_('Repeat password')}</label>
        </div>
        <form:error name="agree"/>
        <div class="form-field" style="clear: right;">
          <label for="agree">${_('I agree to the ')} <a href="${url(controller='home', action='terms')}">${_('terms of use')}</a></label>
          <input type="checkbox" name="agree" value="true" style="float: right;"/>
        </div>
        <div class="form-field" style="clear: right;">
          <span class="btn">
            <input type="submit" value="${_('Register')}"/>
          </span>
        </div>
      </form>
  </%self:portlet>
</%def>
