<%inherit file="/base.mako" />

<%def name="head_tags()">
   <title>${c.person}</title>
</%def>

<h1>Hello</h1>

% for person in c.persons:
<p>${person.name}</p>
% endfor
