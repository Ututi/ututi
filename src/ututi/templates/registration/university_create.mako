<%inherit file="/registration/base.mako" />

<%def name="pagetitle()">${_("University information")}</%def>

<%def name="css()">
  ${parent.css()}
  form .textField input,
  form span.helpText,
  form select {
    width: 300px;
  }
  form button.submit {
    margin-top: 35px;
  }
  .allowed-domains-field {
    margin: 2px 0px;
  }
  form .allowed-domains-field input {
    width: 150px;
  }
  form #allowed-domains-container .textField {
    padding-left: 20px;
    background: url('/img/icons.com/contact_small.png') no-repeat 8px center;
  }
  form #add-more-link {
    margin-left: 20px;
  }
</%def>

<form id="university-create-form"
      action="${c.registration.url(action='university_create')}"
      enctype="multipart/form-data"
      method="POST">

  ${h.input_line('title', _("Full University title:"))}
  ${h.select_line('country', _("Country:"), c.countries)}
  ${h.input_line('site_url', _("University website:"))}

  <label for="logo-field">
    <span class="labelText">${_("University logo:")}</span>
    <input type="file" name="logo" id="logo-field" />
    <form:error name="logo" /> <!-- formencode errors container -->
  </label>

  ${h.select_radio('member_policy', _("Accessibility:"), c.policies)}

  <div id="allowed-domains-container">
    <label for="allowed-domains">
      <span class="labelText">${_("Allowed emails:")}</span>
      <div class="textField">
        ${c.user_domain}
      </div>
      <input type="hidden" name="allowed_domains-0" value="${c.user_domain}" />
      %for i in range(1, c.max_allowed_domains):
        <div class="textField allowed-domains-field ${'hidable' if i > 1 else ''}">
          <input type="text" name="allowed_domains-${i}" />
          <form:error name="allowed_domains-${i}" />
        </div>
      %endfor
      <div>
        <a href="#add-more" id="add-more-link">${_("Add more")}</a>
      </div>
    </label>
  </div>

  <script type="text/javascript">
    $('.allowed-domains-field.hidable input').each(function() {
        if ($(this).val().length == 0)
            $(this).closest('.allowed-domains-field').hide();
    });
    function toggle_domain_fields() {
        if ($('input#member_policy_restrict_email').is(':checked') ||
            $('input#member_policy_allow_invites').is(':checked'))
        {
            $('#allowed-domains-container').show();
        }
        else {
            $('#allowed-domains-container').hide();
        }
    }
    /* Hide email fields if PUBLIC is checked. */
    toggle_domain_fields();
    /* Trigger these fields if other options are set. */
    $(".radioField input").click(toggle_domain_fields);
    $('#add-more-link').click(function() {
        $('.allowed-domains-field:hidden').first().show();
        return false;
    });
  </script>

  ${h.input_submit(_("Next"))}
</form>

