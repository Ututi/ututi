${h.literal(_(u"""Hi,
Your friend %(author)s is using Ututi.lt, a portal for students, and
wants to invite you to a group %(group_title)s < %(group_url)s >.  In Ututi
you can find coursework, share files with other members of the group
and use the group forums.

Since you do not appear to be a Ututi user at the moment, to become a
member of this group, you need to register first.

You may register by following this link: < %(link)s >

--
The Ututi team
""") % dict(author=invitation.author.fullname,
            group_title=invitation.group.title,
            group_url=invitation.group.url(qualified=True),
            link=url(controller="home", action="register", hash=invitation.hash, qualified=True)))}
