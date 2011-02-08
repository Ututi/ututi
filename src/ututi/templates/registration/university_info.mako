<%inherit file="/base.mako" />

<h2>${_("University information")}</h2>

<p>
  ${h.literal(_("You are registering to <strong>%(university_name)s</strong> network.") % \
    dict(university_name=c.registration.location.title))}
</p>

<p>
  ${_("People on this network:")}
</p>

<div id="people-box">
  <%
  row1 = c.users[:7]
  row2 = c.users[7:]
  rows = (row1, row2)
  %>
  %for row in rows:
  <div class="people-row">
    %for user in row:
    <div class="person">
      <div class="logo">
        <img src="${user.url(action='logo', width=30)}" alt="${user.fullname}" />
      </div>
      <div class="name">
        ${user.fullname}
      </div>
    </div>
    %endfor
  </div>
  %endfor
</div>

<p>
  ${h.literal(_("It is not your university? Use another email address or %(contact_us_link)s.") % \
    dict(contact_us_link='<a href="#" id="contact-link">' + _("Contact us") + '</a>'))}
</p>

${h.button_to(_("Next"), url(controller='registration', action='personal_info', hash=c.registration.hash))}
