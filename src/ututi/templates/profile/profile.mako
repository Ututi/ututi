<%inherit file="/profile/base.mako" />

<%def name="head_tags()">
  <title>UTUTI – student information online</title>
</%def>

<h1>${c.fullname}</h1>
%if c.emails_confirmed:
<h2>${_('Your confirmed emails:')}</h2>
<ol id="confirmed-emails">
%for email in c.emails_confirmed:
<li>${email}</li>
%endfor
</ol>
%endif

%if c.emails:
  <form method="post" id="email_confirm_form" action="${url('/confirm_emails')}">
  %for email in c.emails:
     <div class="form-field">
          <input type="checkbox" name="email" value="${email}" id="email_${email}"/>
          <label for="email_${email}">${email}</label>
     </div>
  %endfor

<input type="submit" name="submit" value="Confirm"/>
</form>
%endif

<a href="${url('/logout')}">Log out</a>
