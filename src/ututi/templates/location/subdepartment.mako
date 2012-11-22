<%inherit file="/location/base.mako" />

<%def name="pagetitle()">
  ${c.subdepartment.title}
</%def>

<div class="subdepartment-description">
  ${h.literal(c.subdepartment.description)}
</div>
