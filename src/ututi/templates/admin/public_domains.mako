<%inherit file="/admin/base.mako" />



<h1>${_('Public email domains')}</h1>

%if c.public_domains:
<h2>${_('List')}</h2>
  %for domain in c.public_domains:
  <div>
    <strong>${domain.domain}</strong>
    (${h.link_to(_('Delete'), url(controller="admin", action="delete_public_domain", id=domain.id)) })
  </div>
  %endfor
%endif

<h2>${_('Add')}</h2>

<form method="post" action="${url(controller='admin', action='public_domains')}"
      name="public_domain_form" id="public_domain_form">
  <% help_text = 'Separate with commas and/or whitespace.' %>
  ${h.input_area('domains', 'Enter domains here', help_text=help_text)}
  ${h.input_submit(_('Add'))}
</form>

