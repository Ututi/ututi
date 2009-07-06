<%inherit file="/base.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<h1>${c.group.title}, ${c.group.year.year}</h1>

<div>
${c.group.description}
</div>
