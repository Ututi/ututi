<%inherit file="/group/home.mako" />

<h1>${_("You have decided not to increase Your group's file limit")}</h1>
<br />
<div class="thank_you">
<p>
${_("We hope You did not increase Your group's file limit because You decided to store Your files "
"in the publicly accessible subject folders and share them with everybody :)")}
</p>
<br />
${h.link_to(_("back to the group's files"), url(c.group.url(action="files")), class_="forward-link")}
</div>
