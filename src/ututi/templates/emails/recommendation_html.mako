<h1>${_('Hello!')}</h1>
<p>
  ${_('%(user_name)s has been using VUtuti, a portal for students, for some time now and recommends you to try it.') % dict(user_name=user_name)}
</p>
<p>
${_('VUtuti is a system for students that encourages collaboration and sharing of study materials. We provide tools that make \
storing lecture notes, sharing files and communicating with your classmates much, much easier.')}
</p>
<br />
${_('If You would like to join VUtuti now, please follow this <a href="%(link)s">link</a>.') % dict(link=url('/', qualified=True))|n}
<br />
${_('Looking forward to meeting you,<br/>The VUtuti team')|n}
