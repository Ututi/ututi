<%inherit file="/group/home.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<%def name="head_tags()">
  ${h.stylesheet_link('/stylesheets/forum.css')|n}
</%def>

<h1>${_('Group Files')}</h1>

% for folder in c.group.folders:
  % if folder.title == '':
    % for file in folder:
      ${file.title}
    % endfor
  % else:
    % for file in folder:
    <span>
      ${folder.title}
      ${file.title}
    </span>
    % endfor
  % endif
% endfor

</table>
