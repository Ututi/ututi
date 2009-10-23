<h1>${subject}</h1>

%for section in sections:
<h2>${section['title']}</h2>

<ul>
  %for event in section['events']:
  <li>${event['html_item']|n}</li>
  %endfor
</ul>
%endfor

${_('If you want to stop getting these emails - you can change your subscription settings in your <a href="%(url)s">watched subject page</a>.') % dict(
    url=url(controller='profile', action='subjects', qualified=True))|n}
