<%inherit file="/group/home.mako" />

<h2>${_("You have increased your group's file limit!")}</h2>

<div class="thank_you">
<p>
${_('Once we get confirmation that the payment has been transfered, '
'your group will be able to store an unlimited amount of files.')}
</p>
<p>
${_('Good luck using Ututi groups!')}
</p>

<br />
${h.link_to(_("back to the group's files"), url(c.group.url(action="files")), class_="forward-link")}

</div>
