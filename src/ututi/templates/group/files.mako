<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
</%def>

<h1>${_('Group Files')}</h1>

% for folder in c.group.folders:
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
