${user.fullname},

${_("Your request to join the group %(groupname)s has been confirmed.") % dict(groupname=group.title)}

${_(u"You can visit the group's page at this url: %(url)s .") % dict(url=url(group.url(), qualified=True))}

${_(u"The Ututi team")}
