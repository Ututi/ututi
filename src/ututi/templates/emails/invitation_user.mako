${h.literal(_("""Hello,

Your friend %(author)s wants to invite you to the group
%(group_title)s (%(group_url)s). After joining you will be able to
watch subjects your group is studying, share files with other members
of the group and use the group forum.

You may accept or reject the invitation here: %(invitation_url)s

We hope you will find Ututi useful!

--
The Ututi team
""") % dict(author=invitation.author.fullname,
            group_title=invitation.group.title,
            group_url=invitation.group.url(qualified=True),
            invitation_url=invitation.group.url(action='invitation', accept='True', qualified=True)
))}
