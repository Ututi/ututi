<%inherit file="/base.mako" />
<%namespace file="/portlets/anonymous.mako" import="*"/>

<%def name="head_tags()">
  ${parent.head_tags()}
  ${h.stylesheet_link('/stylesheets/join.css')|n}
  ${h.stylesheet_link('/stylesheets/anonymous.css')|n}
</%def>

<table>
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
