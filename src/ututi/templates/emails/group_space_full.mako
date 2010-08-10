${h.literal(_("""Hello,

your group "%(group_title)s" has just run out of private group space.
If you want to use private group space further, please purchase a subscription
on the <a href="%(group_url)s">group page</a>, and the group file limit
will be raised to 5 GB.
--
The Ututi team
""") % dict(group_title=group.title, group_url=group.url())
)}
