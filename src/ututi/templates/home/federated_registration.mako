<%inherit file="/ubase-sidebar.mako" />
<%namespace name="newlocationtag" file="/widgets/ulocationtag.mako" import="*"/>
<%namespace file="/portlets/user.mako" import="*" />

<%def name="title()">
  Personal information
</%def>

<%def name="portlets()">
  ${blog_portlet()}
  ${user_support_portlet()}
</%def>

<%def name="head_tags()">
  <%newlocationtag:head_tags />
</%def>

<h1>${_('Personal information')}</h1>

<div style="-moz-border-radius: 5px; border: 1px solid #ded8d8; background: #f6f6f6; padding: 1em; margin-top: 1em;">
    <form id="registration_form" method="post" class="fullForm"
          action="${url(controller='home', action='federated_registration')}">
      <fieldset>
        %if c.hash:
          <input type="hidden" name="hash" value="${c.hash}"/>
        %endif
        <form:error name="came_from"/>
        %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
        %endif

    <div style="font-size: 14px; font-weight: bold">${_('1. Personal information')}</div>
    <div style="margin-top: 1em; margin-bottom: 1em; color: #666">
      ${_("You have to provide an email address to be able to participate in your group's mailing list.")}
    </div>

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


    <div style="font-size: 14px; font-weight: bold; border-top: 1px solid #ded8d8; padding-top: 1em; margin-top: 0.5em"
      >${_('2. School (optional)')}</div>
    <div style="margin-top: 1em; margin-bottom: 1em; color: #666">
        ${_("Ututi is an application for students, so it is important for us to know where you study. These data can be changed later in your profile settings screen.")}
    </div>

        <div>
          ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=False)}
        </div>

    ## TODO: Phone number.

    <div style="font-size: 14px; font-weight: bold; border-top: 1px solid #ded8d8; padding-top: 1em; margin-top: 0.5em"
      >${_('3. Phone number (optional)')}</div>
    <div style="margin-top: 1em; margin-bottom: 1em; color: #666">
      ${_("We need your phone number so that you could send and receive SMS messages from the group. Don't worry, we will never send advertisements.")}
    </div>

        <form:error name="phone"/>
        <label>
          <span class="labelText">${_('Phone number')}</span>
          <span class="textField">
            <input type="text" name="phone" value="" />
            <span class="edge"></span>
          </span>
        </label>

        <div style="margin-top: 1em">
          <form:error name="agree"/>
          <label id="agreeWithTOC"><input type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="" onclick="return false;">${_('terms of use')}</a></label>
        </div>

        <button class="btnMedium" type="submit" value="${_('Register')}"><span>${_('Register')}</span></button>
      </fieldset>
    </form>
</div>
