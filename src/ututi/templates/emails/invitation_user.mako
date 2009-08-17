${invitation.user.fullname},

${_(u"%(author)s has invited You to join the group %(group)s.") % dict(author=invitation.author.fullname, group=invitation.group.title)}

${_(u"You can accept or reject this invitation by following this link: %(url)s.") % dict(url=url(controller="group", action="invitation", id=invitation.group.group_id))}

${_(u"The Ututi team")}
