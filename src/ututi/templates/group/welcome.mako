<%inherit file="/group/home.mako" />

<h1>${_('Congratulations, you have created a new group!')}</h1>
<div style="margin: 10px 0;">
${h.literal(_("""
Ututi groups are a communication tool for you and your friends. Here
your group can use the <a href="%(link_to_forums)s">forums</a>, keep
private files and <a href="%(link_to_subjects)s">watch subjects</a>
you are studying.
""") % dict(link_to_forums=c.group.url(action='forum'),
            link_to_subjects=c.group.url(action='subjects')))}
</div>
${parent.body()}
