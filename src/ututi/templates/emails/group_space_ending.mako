${h.literal(_("""Hello,

the private space subscription for the VUtuti group "%(group_title)s"
is about to expire.  When it expires, you will not be able to upload
more files to your file area.  Please extend your subscription on the
group page at %(group_url)s .

--
The VUtuti team
""") % dict(group_title=group.title, group_url=group.url(qualified=True))
)}
