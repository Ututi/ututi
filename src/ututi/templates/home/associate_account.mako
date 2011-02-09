<%inherit file="/ubase-sidebar.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*" />

<%def name="title()">
  Associate account
</%def>

<%def name="portlets()">
</%def>

<h1>${_('Associate an existing Ututi account')}</h1>

<div>${_('Enter the user name and password for your existing Ututi account.')}</div>

<form id="join_login_form" method="post" action="${url(controller='home', action='associate_account')}" class="fullForm">
    %if c.came_from:
      <input type="hidden" name="came_from" value="${c.came_from}" />
    %endif
    %if c.login_error:
      <div class="error">${c.login_error}</div>
    %endif
    ${h.input_line('login_username', _('Your email address'), value=request.params.get('login'))}
    ${h.input_psw('login_password', _('Password'))}
    ${h.input_submit(_('Log in & associate'))}
  </form>

  <div style="padding-bottom: 2em; padding-top: 5px; padding-right: 33px">
     <a href="${url(controller='home', action='pswrecovery')}">${_('Forgotten password?')}</a>
  </div>
