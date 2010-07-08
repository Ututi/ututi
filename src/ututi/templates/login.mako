<%inherit file="/ubase.mako" />

<%namespace file="/search/index.mako" import="search_form"/>
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="head_tags()">
${parent.head_tags()}
<meta name="robots" content="noindex, nofollow" />
</%def>

<%def name="body_class()">anonymous_index</%def>

<%def name="portlets()">
</%def>


<h1>${c.header}</h1>
<table style="width: 100%;" id="login-screen">
  <tr>
    <td style="vertical-align: top; padding: 15px 20px 0 0;">
      <div id="login_message" class="${c.message_class or 'permission-denied'}">
        ${c.message|n}
        %if c.final_msg:
        <p>
          ${c.final_msg|n}
        </p>
        %endif
      </div>
        %if c.show_login:
          <hr style="border: 0; border-top: 1px solid #ded8d8;"/>
          <div id="login-page-form">
            ${ututi_login_section_portlet()}
          </div>
        %else:
          <div id="federated-login-note">
            ${_('Log in or register with your Google or Facebook account.')}
          </div>
          <div id="federated-login-buttons">
            <a href="${url(controller='home', action='google_register')}" id="google-button">
              ${h.image('/img/google-logo.gif', alt='Log in using Google', class_='google-login')}
            </a>
            <br />
            <fb:login-button perms="email"
              onlogin="show_loading_message(); window.location = '${url(controller='home', action='facebook_login')}'"
             >Connect</fb:login-button>
          </div>
        %endif

      </div>
    </td>
    <td style="width: 360px;">
      ${ututi_join_section_portlet()}
    </td>
  </tr>
</table>

