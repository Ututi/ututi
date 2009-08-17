${_(u"%(author)s has invited You to join the group %(group)s.") % dict(author=invitation.author.fullname, group=invitation.group.title)}

${_(u"Since You do not appear to be a Ututi user at the moment, to become a member of this group, You will have to register first.")}

${_(u"You can do this by following this link: %(link)s .") % dict(link=url(controller="home", action="register", hash=invitation.hash, qualified=True))}

${_(u"The Ututi team")}
