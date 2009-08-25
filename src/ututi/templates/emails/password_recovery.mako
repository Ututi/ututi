${user.fullname},

${_(u"We have received a request to reset Your password on the Ututi system. If You did not request the password to be recovered, please ignore this message.")}

${_(u"If You did forget Your password, follow this link to recover it:")}

${url(controller='home', action='recovery', key=user.recovery_key, qualified=True)}

${_('Ututi team')}
