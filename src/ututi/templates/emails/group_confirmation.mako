${user.fullname},

${_("Your request to join the group %(groupname)s has been confirmed.") % dict(groupname=group.title)}

${_(u"You may visit the group's page here: %(url)s .") % dict(url=url(group.url(), qualified=True))}

${_(u"The VUtuti team")}
