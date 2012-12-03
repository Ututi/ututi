%if message:
${_('Hi')}

${message}

${_('You may join group %(group_title)s by following this link:') % dict(group_title=invitation.group.title)}
${registration.url(action='confirm_email', qualified=True)}

--
${invitation.author.fullname}
%else:
${h.literal(_(u"""Hello,

Your friend %(author)s is using VUtuti, academical social networtk, and
wants to invite you to a group %(group_title)s (%(group_url)s).
In VUtuti you can find coursework, share files with other members of 
the group and use the group forums.

Since you do not appear to be a VUtuti user at the moment, to become a
member of this group, you need to register first.

You may register by following this link: %(link)s

--
The VUtuti team
""") % dict(author=invitation.author.fullname,
            group_title=invitation.group.title,
            group_url=invitation.group.url(qualified=True),
            link=registration.url(action='confirm_email', qualified=True)))}
%endif
