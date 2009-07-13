<%inherit file="/base.mako" />

<%def name="title()">
  ${c.subject.title}
</%def>

<h1>${c.subject.title}</h1>

<div>
${c.subject.lecturer}
</div>

<h2>${_('Files')}</h2>

% for folder in c.subject.folders:
<ul>
  % if folder.title == '':
    % for file in folder:
  <li>
      ${file.title}
  </li>
    % endfor
  % else:
    % for file in folder:
    <li>
      ${folder.title}
      ${file.title}
    </li>
    % endfor
  % endif
</ul>
% endfor
