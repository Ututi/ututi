${h.literal(_("""Hello,

the private space subscription for the Ututi group "%(group_title)s"
is about to expire.  When it expires, you will not be able to upload
more files to your file area.  Please extend your subscription on the
<a href="%(group_url)s">group page</a>.
--
The Ututi team
""") % dict(group_title=group.title, group_url=group.url())
)}
