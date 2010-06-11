<%inherit file="/ubase-nomenu.mako" />
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="body_class()">join anonymous_index noMenu</%def>
<br />
%if c.access_denied:
<h1>${_('Permission denied!')}</h1>

<img src="${url('/images/details/icon_nope.png')}" />

<div>
${_('You do not have the rights to see this page, or perform this action. Go back or go to the search page please.')}
</div>
%endif
<table style="width: 955px;">
  <tr>
    <td style="width: 355px;">
      ${ututi_join_section_portlet()}
    </td>
    <td style="width: 245px;">
      <div id="decision" style="text-align: center;">
        ${_('Already have an account? Login!')}
      </div>
    </td>
    <td style="width: 355px;">
      ${ututi_login_section_portlet()}
    </td>
  </tr>
</table>
