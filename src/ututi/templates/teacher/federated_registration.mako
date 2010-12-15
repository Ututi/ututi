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

<div class="federated-registration-form">
    <form id="registration_form" method="post" class="fullForm"
          action="${url(controller='teacher', action='federated_registration')}">
      <fieldset>
        <form:error name="invitation_hash"/>

        <input type="hidden" name="invitation_hash" value="" />

        %if c.came_from:
          <input type="hidden" name="came_from" value="${c.came_from}" />
        %endif

        <div class="heading">${_('1. Personal information')}</div>
        <div class="comment">
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
        <input type="hidden" id="gadugadu" name="gadugadu"/>

    <div class="heading">${_('2. School')}</div>
    <div class="comment">
        ${_("Tell us where You teach, so that we can verify You. Additional schools can be added after registration.")}
    </div>

        <div>
          ${location_widget(2, add_new=(c.tpl_lang=='pl'), live_search=False)}
        </div>
        <div>
          ${h.input_line('position', _('Position'))}
        </div>

        <input type="hidden" name="phone" value="" />

        <div style="margin-top: 1em">
          <form:error name="agree"/>
          <label id="agreeWithTOC"><input class="checkbox" checked="checked" type="checkbox" name="agree" value="true"/>${_('I agree to the ')} <a href="${url(controller='home', action='terms')}">${_('terms of use')}</a></label>
        </div>

        <br />
        <button class="btnMedium" type="submit" value="${_('Register')}"><span>${_('Register')}</span></button>

        <span style="margin-left: 1em">
          ${h.link_to(_('I am already a registered Ututi user'), url(controller='home', action='associate_account'))}
        </span>

      </fieldset>
    </form>
</div>
