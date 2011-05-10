<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("University information")}</%def>

<%def name="css()">
  ${parent.css()}

  #people-on-this-network {
    margin-top: 20px;
  }

  div#people-box {
    width: 420px;
    border: 1px solid #666666;
    margin: -2px;
    padding: 10px 0 0 10px;
  }

    div#people-box div.person {
      float: left;
      margin: 0 10px 10px 0;
    }

      div#people-box div.logo,
      div#people-box div.name {
        width: 50px;
        font-size: 9px;
      }
</%def>

<p>
  <span class="notification">
  ${h.literal(_("You are registering to <strong>%(university_name)s</strong> network.") % \
    dict(university_name=c.registration.location.title))}
  </span>
</p>

<div id="people-on-this-network">
  <p>
    ${ungettext("%(count)s person on this network:",
                "%(count)s people on this network:",
                c.user_count) % dict(count=c.user_count)}
  </p>

  <div id="people-box">
    <%
    row1 = c.users[:7]
    row2 = c.users[7:]
    rows = (row1, row2)
    %>
    %for row in rows:
      %if row:
      <div class="row clearfix">
        %for user in row:
        <div class="person">
          <div class="logo">
            <img src="${user.url(action='logo', width=45)}" alt="${user.fullname}" />
          </div>
          <div class="name break-word">
            ${h.object_link(user)}
          </div>
        </div>
        %endfor
      </div>
      %endif
    %endfor
  </div>

</div>

<p>
  ${h.literal(_("It is not your university? Use another email address or %(contact_us_link)s.") % \
    dict(contact_us_link=h.link_to(_("Contact us"), url(controller='home', action='contacts'), id="contact-link")))}
</p>

${h.button_to(_("Next"),
              c.registration.url(action='personal_info'),
              class_='next',
              method='GET')}
