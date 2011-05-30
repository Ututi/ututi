<%inherit file="/location/edit_base.mako" />

<%def name="css()">
  ${parent.css()}
  .left-right {
    margin-top: 20px;
  }
  .email-domains .delete-button {
    display: inline;
  }
</%def>

<div class="left-right">
  <div class="left">
    <div class="explanation-post-header" style="margin-top:0">
      <h2>${_('Registration control')}</h2>
      <p class="tip">
        ${_("Choose who can join your social network.")}
      </p>
    </div>
    <form action="${c.location.url(action='edit_registration')}" method="post" class="narrow">
      ${h.member_policy_select(_("Choose your policy:"))}
      ${h.input_submit()}
    </form>
  </div>
  <div class="right">
    <div class="explanation-post-header" style="margin-top:0">
      <h2>${_('Email domains')}</h2>
      <p class="tip">
        ${_("Enter a list of email domains that belong to your university. "
            "This is particularly important if you want to control who is registering to your network.")}
      </p>
    </div>
    <ul class="email-domains icon-list">
    %if c.location.email_domains:
      %for domain in c.location.email_domains:
        <li class="icon-email-domain">
          ${domain.domain_name}
          <form action="${c.location.url(action='delete_domain')}" method="post" class="delete-button">
            <input type="hidden" name="domain_id" value="${domain.id}" />
            <input type="image" src="/img/icons.com/close.png" title="${_('Delete this domain')}" />
          </form>
        </li>
      %endfor
    %else:
      <p class="warning">
        ${_("Currently no email domains are assigned to this University.")}
    %endif
    <form action="${c.location.url(action='add_domain')}" method="post" class="narrow">
      ${h.input_line('domain_name', _("New email domain:"))}
      ${h.input_submit(_("Add"), class_='inline dark add')}
    </form>
    </ul>
  </div>
</div>
