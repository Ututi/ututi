${_(u"%(fullname)s has requested to become a member of the group %(groupname)s.") % dict(fullname=user.fullname, groupname=group.title)}

${_(u"You can confirm or deny this request at this url: %(url)s .") % dict(url=url(group.url(action='members'), qualified=True))}

${_(u"The Ututi team")}
