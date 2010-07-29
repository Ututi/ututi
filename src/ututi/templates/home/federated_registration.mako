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
        <form:error name="invitation_hash"/>

        <input type="hidden" name="invitation_hash" value="" />

        %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
        %endif

        <div style="font-size: 14px; font-weight: bold">${_('1. Personal information')}</div>
        <div style="margin-top: 1em; margin-bottom: 1em; color: #666; font-size: 12px">
            ${_("Please check that your personal information is correct.")}
        </div>

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
    <div style="margin-top: 1em; margin-bottom: 1em; color: #666; font-size: 12px">
        ${_("Ututi is an application for students, so it is important for us to know where you study. These data can be changed later in your profile settings screen.")}
    </div>

        <div>
          ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=False)}
        </div>

    <div style="font-size: 14px; font-weight: bold; border-top: 1px solid #ded8d8; padding-top: 1em; margin-top: 0.5em"
      >${_('3. Phone number (optional)')}</div>
    <div style="margin-top: 1em; margin-bottom: 1em; color: #666; font-size: 12px">
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
          <label id="agreeWithTOC"><input type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}">${_('terms of use')}</a></label>
        </div>

        <button class="btnMedium" type="submit" value="${_('Register')}"><span>${_('Register')}</span></button>

        <span style="margin-left: 1em">
          ${h.link_to(_('I am already a registered Ututi user'), url(controller='home', action='associate_account'))}
        </span>

      </fieldset>
    </form>
</div>
