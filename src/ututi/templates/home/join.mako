<%inherit file="/base.mako" />
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="body_class()">join anonymous_index</%def>

<table style="width: 955px;">
  <tr>
    <td>
      ${ututi_join_section_portlet()}
    </td>
    <td style="width: 245px;">
      <div id="decision">
        ${_('Already have an account? Login!')}
      </div>
    </td>
    <td>
      ${ututi_login_section_portlet()}
    </td>
  </tr>
</table>
