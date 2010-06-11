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
<table style="width: 100%;">
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
          <h2 class="underline">${_('Why should I join?')}</h3>
          <div id="ututi_features">
            <div id="can_find">
              <h3>${_('What can You find here?')}</h3>
              ${_('Group <em>forums</em>, subject <em>wikis</em>, <em>files</em>, lecture notes and <em>answers</em> to \
              questions that matter for your studies.')|n}
            </div>
            <div id="can_do">
              <h3>${_('What can you do here?')}</h3>
              ${_('Store <em>study materials</em> and pass them on for future generations, create <em>academic groups</em> \
              and communicate with groupmates.')|n}
            </div>
          </div>
        %endif

      </div>
    </td>
    <td style="width: 360px;">
      ${ututi_join_section_portlet()}
    </td>
  </tr>
</table>

