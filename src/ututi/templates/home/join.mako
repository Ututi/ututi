<%inherit file="/ubase.mako" />
<%namespace file="/portlets/anonymous.mako" import="*"/>
<%def name="anonymous_menu()"></%def>
<%def name="body_class()">join anonymous_index noMenu</%def>
<br />
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
