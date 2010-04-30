<%inherit file="/group/home.mako" />

<h1>${_("You have decided not to increase your group's file limit")}</h1>
<br />
<div class="thank_you">
<p>
${_("We hope you did not increase uour group's file limit because you decided to store files "
"in the public subject folders and share them with everybody :)")}
</p>
<br />
${h.link_to(_("back to the group's files"), url(c.group.url(action="files")), class_="forward-link")}
</div>
