<%inherit file="/base.mako" />

<%def name="title()">
  ${c.subject.title}
</%def>

<h1>${c.subject.title}</h1>

<div>
${c.subject.lecturer}
</div>
