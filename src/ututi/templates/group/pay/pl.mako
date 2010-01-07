<%inherit file="/group/pay/en.mako" />

<h1>${_("Make your group's file space unlimited")}</h1>
<br />
${_("The amount of group's private files is limited to 200 Mb. This is so because Ututi "
"encourages users to store their files in publicly accessible subjects where they can "
"be shared with all the users. But if You want to keep more than 200 Mb of files, "
"You can do this.")}

<div class="orange_emph">
  ${_('For <em>%d Lt</em> Your group will be able to store an <em>unlimited amount of files</em>:') % (c.group_payment_month / 100)|n}
</div>

<a href="${c.group.url(action='payment_deferred')}" class="btn-large"><span>${_('increase the limit')}</span></a>

<div style="text-align: right;">
  <a class="more" url="${c.group.url(action='files')}">${_("Back to the group's files")}</a>
</div>
