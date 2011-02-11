<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("University information")}</%def>

<%def name="css()">
  ${parent.css()}

  #people-on-this-network {
    margin-top: 20px;
  }

  table#people-box {
    width: auto;
    border: 1px solid #666666;
    padding: 0 10px 10px 10px;
    margin: -2px;
  }

    table#people-box td {
      width: 50px;
      padding-right: 15px;
    }

      table#people-box td.logo {
        padding-top: 10px;
        vertical-align: bottom;
      }

      table#people-box td.name {
        vertical-align: top;
        font-size: 9px;
        word-wrap: wrap;
      }
</%def>

<p>
  ${h.literal(_("You are registering to <strong>%(university_name)s</strong> network.") % \
    dict(university_name=c.registration.location.title))}
</p>

<div id="people-on-this-network">
  <p>
    ${_("People on this network:")}
  </p>

  <table id="people-box">
    <%
    row1 = c.users[:7]
    row2 = c.users[7:]
    rows = (row1, row2)
    %>
    %for row in rows:
      %if row:
      <tr class="logos">
        %for user in row:
        <td class="logo">
          <img src="${user.url(action='logo', width=45)}" alt="${user.fullname}" />
        </td>
        %endfor
      </tr>
      <tr class="names">
        %for user in row:
        <td class="name">
          ${h.object_link(user)}
        </td>
        %endfor
      </tr>
      %endif
    %endfor
  </table>
</div>

<p>
  ${h.literal(_("It is not your university? Use another email address or %(contact_us_link)s.") % \
    dict(contact_us_link='<a href="#" id="contact-link">' + _("Contact us") + '</a>'))}
</p>

${h.button_to(_("Next"),
              url(controller='registration', action='personal_info', hash=c.registration.hash),
              class_='next',
              method='GET')}
