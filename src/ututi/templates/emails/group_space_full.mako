${h.literal(_("""Hello,

your group "%(group_title)s" has just run out of private group space.
If you want to use private group space further, please purchase a subscription
on the group page at %(group_url)s, and the group file limit
will be raised to %(size)s.

--
The VUtuti team
""") % dict(group_title=group.title, group_url=group.url(qualified=True), size=h.file_size(size_limit))
)}
