<%inherit file="/base.mako" />

<%def name="title()">
  ${c.group.title}
</%def>

<h1>${c.group.title}, ${c.group.year.year}</h1>

% for message in c.messages:
<div>
  <div>${message.author.fullname} -- ${message.subject}</div>
  <pre>
    ${message.body}
  </pre>
  % if message.attachments:
  <ul>
    % for file in message.attachments:
      <li>
         <a href="${h.url_for(controller='files', action='get', id=file.id)}" class="file-link">${file.title}</a>
      </li>
    % endfor
  </ul>
  % endif
</div>
% endfor
</table>
