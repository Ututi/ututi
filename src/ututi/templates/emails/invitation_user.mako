${h.literal(_("""Hi,
Your friend %(author)s wants to wants to invite You into a group
%(group_title)s < %(group_url)s >. After joining you will be able to
watch subjects your group is studying, share files with other members
of the group and use the group forum.

You can accept or reject the invitation here: < %(invitation_url)s >

We hope You will find Ututi useful!

--
Ututi komanda
""") % dict(author=invitation.author.fullname,
            group_title=invitation.group.title,
            group_url=invitation.group.url(qualified=True),
            invitation_url=url(controller="group", action="invitation", id=invitation.group.group_id, qualified=True)
))}
