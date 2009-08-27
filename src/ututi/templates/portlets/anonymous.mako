<%inherit file="/portlets/base.mako"/>

<%def name="ututi_join_portlet()">
  <%self:portlet id="ututi_join_portlet">
    <%def name="header()">
      ${_('Become a part of Ututi')}
    </%def>
      <form id="registration_form" method="post" action="${url('/register')}">
        <div class="form-field">
          <input class="line" type="text" id="fullname" name="fullname" size="40"/>
          <label for="fullname">${_('Fullname')}</label>
        </div>
        <div class="form-field">
          <input class="line" type="text" id="email" name="email" size="40"/>
          <label for="email">${_('Email')}</label>
        </div>
        <div class="form-field">
          <input class="line" type="password" id="new_password" name="new_password" size="40"/>
          <label for="new_password">${_('Password')}</label>
        </div>
        <div class="form-field">
          <input class="line" type="password" id="repeat_password" name="repeat_password" size="40"/>
          <label for="repeat_password">${_('Repeat password')}</label>
        </div>
        <div class="form-field">
          <span class="btn">
            <input type="submit" value="${_('Register')}"/>
          </span>
        </div>
      </form>
      <br style="clear: right;" />
  </%self:portlet>
</%def>
