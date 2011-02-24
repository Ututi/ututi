${message}

---

${_('%(user_name)s has been using Ututi, a portal for students, for some time now and recommends you to try it.') % dict(user_name=inviter.fullname)}

${_('Ututi is a system for students that encourages collaboration and sharing of study materials. We provide tools that make \
storing lecture notes, sharing files and communicating with your classmates much, much easier.')}

${_('If you would like to join Ututi now, please follow this link:')}
${registration.url(action='confirm_email', qualified=True)}

${_('The Ututi team')}
