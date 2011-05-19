${subject}

%for section in sections:
${section['title']} (${section['url']})

%for event in section['events']:
- ${event['text_item']}
%endfor
%endfor

${_('If you want to stop getting these emails - you can change your subscription settings in your notification settings page (%(url)s).') % dict(
    url=url(controller='profile', action='notification_settings', qualified=True)) }
