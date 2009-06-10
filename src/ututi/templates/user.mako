<%inherit file="/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${c.fullname}</h1>

<form method="post" id="email_confirm_form" action="/confirm_emails">
%for email in c.emails:
     <div class="form-field">
          <input type="checkbox" name="email" value="${email}" id="email_${email}"/>
          <label for="email_${email}">${email}</label>
     </div>
%endfor
<input type="submit" name="submit" value="Confirm"/>
</form>

<a href="/logout">Log out</a>
