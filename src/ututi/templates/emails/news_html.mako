<h3>${subject}</h3>

%for section in sections:
<h4><a href="${section['url']}">${section['title']}</a></h4>

<ul>
  %for event in section['events']:
  <li>${event['html_item']|n}</li>
  %endfor
</ul>
%endfor

${_('If you want to stop getting these emails - you can change your subscription settings in your <a href="%(url)s">notification settings page</a>.') % dict(
    url=url(controller='profile', action='notification_settings', qualified=True))|n}
