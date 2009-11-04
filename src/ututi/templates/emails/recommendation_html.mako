<h1>${_('Hello!')}</h1>
<p>
${_('%(user_name)s has been using Ututi - the portal for students - for some time now and is recommending you to try it.') % dict(user_name=user_name)}
</p>
<p>
${_('Ututi is a system for students that encourages collaboration and sharing of study materials. We provide tools that make \
storing lecture notes, sharing files and communicating with your class mates much, much easier.')}
</p>
<br />
${_('If You would like to join Ututi now, please follow this <a href="%(link)s">link</a>.') % dict(link=url('/', qualified=True))|n}
<br />
${_('Looking forward to meeting You,<br/>The Ututi team')|n}
