<%inherit file="/admin/base.mako" />
<%namespace file="/sections/content_snippets.mako" import="item_location_full" />

<h1>${_('Email domains')}</h1>

%if c.public_domains:
<h2>${_('List')}</h2>
<table style="width: 400px">
  <tr>
    <th>Domain</th>
    <th>University</th>
    <th>Actions</th>
  </tr>
  %for domain in c.public_domains:
  <tr>
    <td>
      <strong>
        <span class="domain-name">${domain.domain_name}</span>
      </strong>
    </td>
    <td>
      <span class="domain-location">
        %if domain.location is None:
          (Public)
        %else:
          ${item_location_full(domain)}
        %endif
      </span>
    </td>
    <td style="text-align: center">
      ${h.link_to(_('Delete'), url(controller="admin", action="delete_email_domain", id=domain.id)) }
    </td>
  </div>
  %endfor
</table>
%endif

<h2>${_('Add')}</h2>

<form method="post" action="${url(controller='admin', action='email_domains')}"
      name="email_domain_form" id="email_domain_form">
  <% help_text = 'Separate with commas and/or whitespace.' %>
  ${h.select_line('location_id', 'University (or public)', c.uni_options)}
  ${h.input_area('domains', 'Enter domains here', help_text=help_text)}
  ${h.input_submit(_('Add'))}
</form>

